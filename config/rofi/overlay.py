#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GtkLayerShell, GLib
import time, math

class Overlay(Gtk.Window):
    def __init__(self):
        super().__init__()
        self.set_decorated(False)
        self.set_app_paintable(True)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self, "screen-overlay")
        GtkLayerShell.set_keyboard_interactivity(self, False)
        for edge in (
            GtkLayerShell.Edge.LEFT,
            GtkLayerShell.Edge.RIGHT,
            GtkLayerShell.Edge.TOP,
            GtkLayerShell.Edge.BOTTOM,
        ):
            GtkLayerShell.set_anchor(self, edge, True)
        GtkLayerShell.set_exclusive_zone(self, -1)

        monitor = Gdk.Display.get_default().get_monitor_at_point(0, 0)
        w = monitor.get_geometry().width
        h = monitor.get_geometry().height
        self.set_default_size(w, h)

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        self.connect("draw", self.on_draw)
        self.connect("destroy", Gtk.main_quit)

        self.start_time = time.time()
        self.phase = "white_in"
        self.phase_start = time.time()
        self.duration_white = 0.1
        self.duration_reveal = 0.35

        GLib.timeout_add(16, self.tick)
        self.show_all()

    def tick(self):
        if time.time() - self.phase_start > 5:
            self.destroy()
            return False
        self.queue_draw()
        return True

    def on_draw(self, widget, cr):
        now = time.time()
        alloc = self.get_allocation()
        w = alloc.width
        h = alloc.height

        if self.phase == "white_in":
            elapsed = now - self.phase_start
            progress = min(elapsed / self.duration_white, 1.0)
            cr.set_source_rgba(1, 1, 1, progress)
            cr.rectangle(0, 0, w, h)
            cr.fill()
            if progress >= 1.0:
                self.phase = "reveal"
                self.phase_start = now

        elif self.phase == "reveal":
            elapsed = now - self.phase_start
            progress = min(elapsed / self.duration_reveal, 1.0)
            eased = 1 - (1 - progress) ** 3

            cx, cy = w / 2, h / 2
            max_r = math.sqrt(cx**2 + cy**2)
            r = max_r * eased

            cr.set_operator(cairo.OPERATOR_SOURCE)
            cr.set_source_rgba(1, 1, 1, 1)
            cr.rectangle(0, 0, w, h)
            cr.fill()

            cr.set_operator(cairo.OPERATOR_CLEAR)
            cr.arc(cx, cy, r, 0, 2 * math.pi)
            cr.fill()

            cr.set_operator(cairo.OPERATOR_OVER)

            if progress >= 1.0:
                self.destroy()
                return False

        return True

import cairo
Overlay()
Gtk.main()
