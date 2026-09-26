/* rofi-fx — rofi arayüz parçaları birleşme / dağılma animasyonu.
 *
 * Kullanım: rofi-fx assemble | disassemble
 * Fullscreen transparent gtk-layer-shell overlay; klavye çalmaz,
 * süresi dolunca kendiliğinden kapanır.
 */
#include <gtk/gtk.h>
#include <gtk-layer-shell.h>
#include <cairo.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define WW 760.0
#define WH 560.0

typedef enum { P_SEARCH, P_PILL, P_ROW, P_HINT } PieceKind;

typedef struct {
    PieceKind kind;
    int sel;
    double x, y;     /* hedef (rofi iskeleti) */
    double sx, sy;   /* başlangıç (ekran dışı) */
    double w, h;     /* pill için; diğerleri sabit */
    double delay;
} Piece;

static Piece pieces[64];
static int n_pieces = 0;
static gint64 t0;
static double DURATION, MOVE;
static int reverse_mode = 0; /* 0=assemble, 1=disassemble */
static int mon_w = 1920, mon_h = 1080;
static double frag_cx, frag_cy; /* dağılma merkezi */

/* dağılma parçacığı: tema renklerinde hap/kare kırıklar */
typedef struct {
    double x, y;     /* başlangıç (merkez çevresi) */
    double vx, vy;   /* hız (px/sn, ease ile) */
    double w, h, r;
    double delay;
    int color;       /* 0=cyan 1=koyu 2=açık mavi 3=mor */
} Frag;
static Frag frags[20];
static int n_frags = 0;

/* fx-colors dosyasından tema renkleri (yoksa gömülü varsayılan) */
static double C_ACC[3] = {0.20, 0.80, 1.00};
static double C_SUR[3] = {0.12, 0.12, 0.15};
static double C_LGT[3] = {0.83, 0.85, 0.88};
static double C_DTX[3] = {0.02, 0.01, 0.04};

static void load_fx_colors(void) {
    const char *home = getenv("HOME");
    char path[512];
    snprintf(path, sizeof(path), "%s/.config/rofi/fx-colors",
             home ? home : "/home/suleyman");
    FILE *f = fopen(path, "r");
    if (!f) return;
    char line[128];
    while (fgets(line, sizeof(line), f)) {
        unsigned r, g, b;
        if (sscanf(line, "accent=#%2x%2x%2x", &r, &g, &b) == 3) {
            C_ACC[0] = r / 255.0; C_ACC[1] = g / 255.0; C_ACC[2] = b / 255.0;
        } else if (sscanf(line, "surface=#%2x%2x%2x", &r, &g, &b) == 3) {
            C_SUR[0] = r / 255.0; C_SUR[1] = g / 255.0; C_SUR[2] = b / 255.0;
        } else if (sscanf(line, "light=#%2x%2x%2x", &r, &g, &b) == 3) {
            C_LGT[0] = r / 255.0; C_LGT[1] = g / 255.0; C_LGT[2] = b / 255.0;
        } else if (sscanf(line, "darktext=#%2x%2x%2x", &r, &g, &b) == 3) {
            C_DTX[0] = r / 255.0; C_DTX[1] = g / 255.0; C_DTX[2] = b / 255.0;
        }
    }
    fclose(f);
}

static double ease_out(double p) {
    double q = 1.0 - p;
    return 1.0 - q * q * q;
}

static void add_piece(Piece p) { pieces[n_pieces++] = p; }

static void build_pieces(void) {
    double cx = mon_w / 2.0, cy = mon_h / 2.0;
    double wx = cx - WW / 2.0, wy = cy - WH / 2.0;
    double off_l = -500.0, off_r = mon_w + 500.0;
    int i;

    add_piece((Piece){P_SEARCH, 0, wx + 18, wy + 18, wx + 18, -120.0, 0, 0, 0.0});
    double pw = (724.0 - 30.0) / 4.0;
    for (i = 0; i < 4; i++) {
        double x = wx + 18 + i * (pw + 10);
        add_piece((Piece){P_PILL, i == 0, x, wy + 94,
                          (i % 2 ? off_l : off_r), wy + 94,
                          pw, 36, 0.03 + 0.025 * i});
    }
    for (i = 0; i < 7; i++) {
        double y = wy + 142 + i * 50;
        add_piece((Piece){P_ROW, i == 0, wx + 18, y,
                          (i % 2 ? off_r : off_l), y,
                          0, 0, 0.05 + 0.02 * i});
    }
    add_piece((Piece){P_HINT, 0, wx + 18, wy + 498, wx + 18,
                      mon_h + 80.0, 0, 0, 0.12});

    /* dağılma merkezi: rofi penceresinin ortası */
    frag_cx = wx + WW / 2.0;
    frag_cy = wy + WH / 2.0;
    n_frags = 0;
    for (int k = 0; k < 18; k++) {
        double ang = 2 * G_PI * k / 18.0 + g_random_double_range(-0.3, 0.3);
        double spd = g_random_double_range(700.0, 1500.0);
        int sq = g_random_int_range(0, 3) == 0;
        double w = sq ? g_random_double_range(24, 40)
                      : g_random_double_range(70, 200);
        double h = sq ? w : g_random_double_range(22, 44);
        frags[n_frags++] = (Frag){
            frag_cx + g_random_double_range(-260, 260),
            frag_cy + g_random_double_range(-180, 180),
            spd * cos(ang), spd * sin(ang),
            w, h, sq ? 4 : 6,
            g_random_double_range(0.0, 0.05),
            g_random_int_range(0, 4),
        };
    }
}

static void rounded(cairo_t *cr, double x, double y, double w, double h, double r) {
    double m = fmin(w / 2.0, h / 2.0);
    if (r > m) r = m;
    cairo_new_sub_path(cr);
    cairo_arc(cr, x + w - r, y + r, r, -G_PI / 2, 0);
    cairo_arc(cr, x + w - r, y + h - r, r, 0, G_PI / 2);
    cairo_arc(cr, x + r, y + h - r, r, G_PI / 2, G_PI);
    cairo_arc(cr, x + r, y + r, r, G_PI, 3 * G_PI / 2);
    cairo_close_path(cr);
}

static double elapsed(void) {
    return (g_get_monotonic_time() - t0) / 1000000.0;
}

static double global_alpha(double t) {
    double a = fmin(1.0, t * 9.0);
    if (t > MOVE)
        a *= fmax(0.0, 1.0 - (t - MOVE) / (DURATION - MOVE));
    return a;
}

static gboolean on_draw(GtkWidget *widget, cairo_t *cr, gpointer data) {
    (void)widget; (void)data;
    double t = elapsed();

    if (reverse_mode) {
        /* merkez flaşı: rofi'nin sönüşünü maskeler */
        double fk = fmin(1.0, t / 0.12);
        if (fk < 1.0 || t < 0.2) {
            double fa = (1.0 - fmin(1.0, t / 0.2)) * 0.45;
            cairo_arc(cr, frag_cx, frag_cy, 60 + 220 * fk, 0, 2 * G_PI);
            cairo_set_source_rgba(cr, 0.55, 0.9, 1.0, fa);
            cairo_fill(cr);
        }
        static const double cols[4][3] = {
            {0.20, 0.80, 1.00}, {0.11, 0.12, 0.15},
            {0.54, 0.71, 0.98}, {0.64, 0.48, 0.91},
        };
        for (int i = 0; i < n_frags; i++) {
            Frag *f = &frags[i];
            double lt = (t - f->delay) / MOVE;
            if (lt <= 0) continue;
            if (lt > 1) lt = 1;
            double e = ease_out(lt);
            double x = f->x + f->vx * MOVE * e;
            double y = f->y + f->vy * MOVE * e;
            double a = fmin(1.0, t * 12.0);
            if (t > MOVE * 0.55)
                a *= fmax(0.0, 1.0 - (t - MOVE * 0.55) / (DURATION - MOVE * 0.55));
            rounded(cr, x - f->w / 2, y - f->h / 2, f->w, f->h, f->r);
            if (f->color == 1)
                cairo_set_source_rgba(cr, cols[1][0], cols[1][1], cols[1][2], 0.85 * a);
            else
                cairo_set_source_rgba(cr, cols[f->color][0], cols[f->color][1],
                                      cols[f->color][2], 0.9 * a);
            cairo_fill(cr);
        }
        return FALSE;
    }

    double a_all = global_alpha(t);

    for (int i = 0; i < n_pieces; i++) {
        Piece *p = &pieces[i];
        double lt = (t - p->delay) / MOVE;
        if (lt <= 0) continue;
        if (lt > 1) lt = 1;
        double e = ease_out(lt);
        if (reverse_mode) e = 1.0 - e; /* birleşikten dışa */
        double w = p->w, h = p->h;
        if (p->kind == P_SEARCH) { w = 724.0; h = 64.0; }
        else if (p->kind == P_ROW) { w = 724.0; h = 44.0; }
        else if (p->kind == P_HINT) { w = 724.0; h = 32.0; }
        double x = p->sx + (p->x - p->sx) * e;
        double y = p->sy + (p->y - p->sy) * e;
        double a = a_all * (0.35 + 0.65 * lt);

        if (p->kind == P_SEARCH) {
            rounded(cr, x, y, w, h, 8);
            cairo_set_source_rgba(cr, C_SUR[0], C_SUR[1], C_SUR[2], 0.95 * a);
            cairo_fill_preserve(cr);
            cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2], 0.35 * a);
            cairo_set_line_width(cr, 1);
            cairo_stroke(cr);
            rounded(cr, x + 8, y + 8, 205, 48, 6);
            cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2], 0.95 * a);
            cairo_fill(cr);
        } else if (p->kind == P_PILL) {
            rounded(cr, x, y, w, h, 6);
            if (p->sel) {
                cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2], 0.16 * a);
                cairo_fill_preserve(cr);
                cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2], 0.45 * a);
                cairo_set_line_width(cr, 1);
                cairo_stroke(cr);
            } else {
                cairo_set_source_rgba(cr, C_SUR[0], C_SUR[1], C_SUR[2], 0.95 * a);
                cairo_fill(cr);
            }
            rounded(cr, x + 16, y + 13, w - 32, 10, 3);
            cairo_set_source_rgba(cr, C_LGT[0], C_LGT[1], C_LGT[2],
                                  (p->sel ? 0.5 : 0.25) * a);
            cairo_fill(cr);
        } else if (p->kind == P_ROW) {
            rounded(cr, x, y, w, h, 8);
            if (p->sel) {
                cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2], 0.95 * a);
                cairo_fill(cr);
            } else {
                cairo_set_source_rgba(cr, C_SUR[0], C_SUR[1], C_SUR[2], 0.75 * a);
                cairo_fill(cr);
            }
            rounded(cr, x + 14, y + 8, 28, 28, 4);
            cairo_set_source_rgba(cr, C_ACC[0], C_ACC[1], C_ACC[2],
                                  (p->sel ? 0.25 : 0.9) * a);
            cairo_fill(cr);
            rounded(cr, x + 54, y + 17, 190, 10, 3);
            if (p->sel)
                cairo_set_source_rgba(cr, C_DTX[0], C_DTX[1], C_DTX[2], 0.85 * a);
            else
                cairo_set_source_rgba(cr, C_LGT[0], C_LGT[1], C_LGT[2], 0.30 * a);
            cairo_fill(cr);
        } else { /* P_HINT */
            rounded(cr, x, y, w, h, 6);
            cairo_set_source_rgba(cr, C_SUR[0], C_SUR[1], C_SUR[2], 0.9 * a);
            cairo_fill(cr);
        }
    }
    return FALSE;
}

static gboolean on_tick(gpointer win) {
    if (elapsed() >= DURATION) {
        gtk_widget_destroy(GTK_WIDGET(win));
        return FALSE;
    }
    gtk_widget_queue_draw(GTK_WIDGET(win));
    return TRUE;
}

int main(int argc, char **argv) {
    if (argc > 1 && strcmp(argv[1], "disassemble") == 0) {
        reverse_mode = 1;
        DURATION = 0.45;
        MOVE = 0.32;
    } else {
        reverse_mode = 0;
        DURATION = 0.55;
        MOVE = 0.36;
    }

    gtk_init(&argc, &argv);

    GdkDisplay *dpy = gdk_display_get_default();
    GdkMonitor *mon = NULL;

    /* argv[2] = "X,Y": animasyonu rofi'nin monitörüne sabitle */
    if (argc > 2) {
        int px0 = 0, py0 = 0;
        if (sscanf(argv[2], "%d,%d", &px0, &py0) == 2)
            mon = gdk_display_get_monitor_at_point(dpy, px0 + 10, py0 + 10);
    }
    if (!mon) {
        GdkSeat *seat = gdk_display_get_default_seat(dpy);
        GdkDevice *ptr = gdk_seat_get_pointer(seat);
        gint px = 0, py = 0;
        gdk_device_get_position(ptr, NULL, &px, &py);
        mon = gdk_display_get_monitor_at_point(dpy, px, py);
    }
    if (!mon) mon = gdk_display_get_primary_monitor(dpy);
    if (!mon) mon = gdk_display_get_monitor(dpy, 0);
    GdkRectangle geo = {0, 0, 1920, 1080};
    if (mon) gdk_monitor_get_geometry(mon, &geo);
    mon_w = geo.width;
    mon_h = geo.height;

    load_fx_colors();
    build_pieces();

    GtkWidget *win = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_decorated(GTK_WINDOW(win), FALSE);
    gtk_widget_set_app_paintable(win, TRUE);

    gtk_layer_init_for_window(GTK_WINDOW(win));
    gtk_layer_set_layer(GTK_WINDOW(win), GTK_LAYER_SHELL_LAYER_OVERLAY);
    gtk_layer_set_namespace(GTK_WINDOW(win), "rofi-fx");
    gtk_layer_set_keyboard_mode(GTK_WINDOW(win),
                                GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(win), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
    gtk_layer_set_exclusive_zone(GTK_WINDOW(win), -1);
    if (mon)
        gtk_layer_set_monitor(GTK_WINDOW(win), mon);

    gtk_widget_set_size_request(win, mon_w, mon_h);

    GdkScreen *scr = gtk_widget_get_screen(win);
    GdkVisual *vis = gdk_screen_get_rgba_visual(scr);
    if (vis) gtk_widget_set_visual(win, vis);

    g_signal_connect(win, "draw", G_CALLBACK(on_draw), NULL);
    g_signal_connect(win, "destroy", G_CALLBACK(gtk_main_quit), NULL);

    t0 = g_get_monotonic_time();
    g_timeout_add(16, on_tick, win);
    gtk_widget_show_all(win);
    gtk_main();
    return 0;
}
