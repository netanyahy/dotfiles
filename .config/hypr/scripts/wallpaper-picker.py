#!/usr/bin/env python3
"""
Wallpaper picker GUI for Hyprland using GTK3 + gtk-layer-shell.
Features:
- Glass transparent UI themed with current Waybar CSS
- Grid of scaled wallpaper thumbnails (GdkPixbuf)
- Keyboard navigation (arrows, Enter, Esc) and mouse selection
- Random wallpaper button
- Swaybg update, current_wallpaper persistence, and desktop notification
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
gi.require_version('GdkPixbuf', '2.0')
gi.require_version('Pango', '1.0')

from gi.repository import Gtk, Gdk, GdkPixbuf, GLib, Pango
import os
import sys
import glob
import shlex
import shutil
import ctypes
import hashlib
import random
import signal
import threading
import subprocess

PID_FILE = "/tmp/wallpaper-picker.pid"

# ── Check Single Instance (toggle behavior) ───────────────────────────────────
def check_single_instance():
    my_pid = os.getpid()
    if os.path.exists(PID_FILE):
        try:
            with open(PID_FILE, "r") as f:
                old_pid = int(f.read().strip())
            if old_pid != my_pid and os.path.exists(f"/proc/{old_pid}"):
                try:
                    with open(f"/proc/{old_pid}/cmdline", "rb") as cf:
                        cmd = cf.read()
                        if b"wallpaper-picker" in cmd:
                            os.kill(old_pid, signal.SIGTERM)
                            try:
                                os.remove(PID_FILE)
                            except Exception:
                                pass
                            sys.exit(0)
                except Exception:
                    pass
        except Exception:
            pass
    try:
        with open(PID_FILE, "w") as f:
            f.write(str(my_pid))
    except Exception:
        pass

# ── Layer Shell via ctypes ────────────────────────────────────────────────────
try:
    _ls = ctypes.CDLL("libgtk-layer-shell.so.0")

    _ls.gtk_layer_init_for_window.argtypes = [ctypes.c_void_p]
    _ls.gtk_layer_init_for_window.restype = None

    _ls.gtk_layer_set_layer.argtypes = [ctypes.c_void_p, ctypes.c_int]
    _ls.gtk_layer_set_layer.restype = None

    _ls.gtk_layer_set_anchor.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    _ls.gtk_layer_set_anchor.restype = None

    _ls.gtk_layer_set_margin.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    _ls.gtk_layer_set_margin.restype = None

    _ls.gtk_layer_set_keyboard_mode.argtypes = [ctypes.c_void_p, ctypes.c_int]
    _ls.gtk_layer_set_keyboard_mode.restype = None

    _ls.gtk_layer_set_namespace.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
    _ls.gtk_layer_set_namespace.restype = None

    _ls.gtk_layer_set_exclusive_zone.argtypes = [ctypes.c_void_p, ctypes.c_int]
    _ls.gtk_layer_set_exclusive_zone.restype = None

    HAS_LAYER_SHELL = True
except OSError:
    HAS_LAYER_SHELL = False

LAYER_OVERLAY = 3
EDGE_LEFT = 0
EDGE_RIGHT = 1
EDGE_TOP = 2
EDGE_BOTTOM = 3
KB_EXCLUSIVE = 1

# GObject C pointer helper
_PyCapsule_GetPointer = ctypes.pythonapi.PyCapsule_GetPointer
_PyCapsule_GetPointer.restype = ctypes.c_void_p
_PyCapsule_GetPointer.argtypes = [ctypes.py_object, ctypes.c_char_p]

def _gptr(gobject):
    return _PyCapsule_GetPointer(gobject.__gpointer__, None)


# ── Wallpaper Scanning & Helpers ──────────────────────────────────────────────
CACHE_DIR = os.path.expanduser("~/.cache/wallpaper-picker")
CURRENT_WALL_FILE = os.path.expanduser("~/.config/hypr/current_wallpaper")

IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp"}
VIDEO_EXTS = {".mp4", ".webm", ".mkv", ".mov", ".gif"}
ALL_EXTS = IMAGE_EXTS | VIDEO_EXTS

def get_current_wallpaper():
    if os.path.isfile(CURRENT_WALL_FILE):
        try:
            with open(CURRENT_WALL_FILE, "r") as f:
                path = f.read().strip()
                if os.path.isfile(path):
                    return os.path.realpath(path)
        except Exception:
            pass
    return None

def find_wallpapers():
    search_dirs = [
        os.path.expanduser("~/Изображения/Wallpapers"),
        os.path.expanduser("~/Pictures/Wallpapers"),
    ]
    discovered = []
    seen_reals = set()
    seen_names = set()

    for sdir in search_dirs:
        if not os.path.isdir(sdir):
            continue
        try:
            entries = sorted(os.listdir(sdir), key=lambda x: x.lower())
        except Exception:
            continue
        for fname in entries:
            _, ext = os.path.splitext(fname)
            if ext.lower() not in ALL_EXTS:
                continue
            fpath = os.path.join(sdir, fname)
            if not os.path.isfile(fpath):
                continue
            try:
                rpath = os.path.realpath(fpath)
            except Exception:
                continue
            if not os.path.isfile(rpath):
                continue
            if rpath in seen_reals or fname in seen_names:
                continue
            seen_reals.add(rpath)
            seen_names.add(fname)
            discovered.append((fname, fpath, rpath))

    return discovered

def get_thumbnail_path(path, width=210, height=130):
    os.makedirs(CACHE_DIR, exist_ok=True)
    h = hashlib.md5(f"{path}_{width}_{height}".encode()).hexdigest()
    return os.path.join(CACHE_DIR, f"{h}.png")

def get_thumbnail(path, width=210, height=130):
    cache_path = get_thumbnail_path(path, width, height)

    try:
        mtime = os.path.getmtime(path)
        if os.path.exists(cache_path) and os.path.getmtime(cache_path) >= mtime:
            return GdkPixbuf.Pixbuf.new_from_file(cache_path)
    except Exception:
        pass

    _, ext = os.path.splitext(path.lower())
    if ext in (VIDEO_EXTS - {".gif"}):
        temp_frame = f"{cache_path}.tmp.png"
        try:
            res = subprocess.run(
                ["ffmpeg", "-y", "-ss", "00:00:01", "-i", path, "-frames:v", "1", "-update", "1", "-q:v", "2", temp_frame],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=5
            )
            if res.returncode != 0 or not os.path.exists(temp_frame) or os.path.getsize(temp_frame) == 0:
                subprocess.run(
                    ["ffmpeg", "-y", "-i", path, "-frames:v", "1", "-update", "1", "-q:v", "2", temp_frame],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=5
                )

            if os.path.exists(temp_frame) and os.path.getsize(temp_frame) > 0:
                pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(temp_frame, width, height, True)
                pb.savev(cache_path, "png", [], [])
                try:
                    os.remove(temp_frame)
                except Exception:
                    pass
                return pb
        except Exception as e:
            print(f"Error generating thumbnail for video {path}: {e}")
            try:
                if os.path.exists(temp_frame):
                    os.remove(temp_frame)
            except Exception:
                pass
        return None
    else:
        try:
            pb = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, width, height, True)
            pb.savev(cache_path, "png", [], [])
            return pb
        except Exception:
            return None

def apply_wallpaper(path):
    if not path or not os.path.isfile(path):
        return

    # 1. Save to ~/.config/hypr/current_wallpaper
    try:
        os.makedirs(os.path.dirname(CURRENT_WALL_FILE), exist_ok=True)
        with open(CURRENT_WALL_FILE, "w") as f:
            f.write(path + "\n")
    except Exception as e:
        print(f"Error saving current_wallpaper: {e}")

    _, ext = os.path.splitext(path.lower())
    is_animated = ext in VIDEO_EXTS

    # 2. Restart appropriate background player
    if is_animated:
        if shutil.which("mpvpaper"):
            cmd = f"pkill swaybg; pkill mpvpaper; nohup mpvpaper -o \"no-audio --loop-playlist shuffle=no\" '*' {shlex.quote(path)} >/dev/null 2>&1 &"
            subprocess.Popen(cmd, shell=True)
        else:
            subprocess.Popen([
                "notify-send",
                "Требуется mpvpaper",
                "Для воспроизведения анимированных обоев установите mpvpaper:\ndoas emerge gui-apps/mpvpaper (Gentoo) или pacman -S mpvpaper (Arch)",
                "-i", "video"
            ])
            return
    else:
        cmd = f"pkill mpvpaper; pkill swaybg; nohup swaybg -i {shlex.quote(path)} -m fill >/dev/null 2>&1 &"
        subprocess.Popen(cmd, shell=True)

    # 3. Notification
    basename = os.path.basename(path)
    thumb_path = get_thumbnail_path(path)
    icon_path = thumb_path if os.path.isfile(thumb_path) else path
    try:
        subprocess.Popen(["notify-send", "Обои обновлены", basename, "-i", icon_path])
    except Exception:
        pass


# ── CSS Theme ─────────────────────────────────────────────────────────────────
def get_theme_css():
    curr_theme = os.path.expanduser("~/.config/waybar/themes/current.css")
    bt_theme = os.path.expanduser("~/.config/waybar/themes/bluetooth_theme.css")
    theme_file = None
    if os.path.isfile(curr_theme):
        theme_file = curr_theme
    elif os.path.isfile(bt_theme):
        theme_file = bt_theme

    import_line = f'@import "{theme_file}";\n' if theme_file else ""

    return f"""
/* Fallback theme variables */
@define-color bg-color rgba(18, 18, 22, 0.85);
@define-color border-color rgba(255, 255, 255, 0.2);
@define-color text-color #ffffff;
@define-color accent-color #ffffff;
@define-color ws-inactive rgba(255, 255, 255, 0.45);
@define-color ws-hover-bg rgba(255, 255, 255, 0.10);
@define-color ws-hover-fg #ffffff;
@define-color ws-active-bg #ffffff;
@define-color ws-active-fg #000000;
@define-color ws-shadow rgba(255, 255, 255, 0.5);
@define-color ws-glow rgba(255, 255, 255, 0.25);
@define-color hover-bg rgba(255, 255, 255, 0.16);

{import_line}

@keyframes fadeIn {{
    from {{ opacity: 0; }}
    to   {{ opacity: 1; }}
}}

window {{
    background: transparent;
}}

#main-frame {{
    background: @bg-color;
    border: 2px solid @accent-color;
    border-radius: 20px;
    box-shadow: 0 8px 32px @ws-glow;
    padding: 18px 22px 22px 22px;
    animation: fadeIn 0.22s ease-out;
}}

#header-title {{
    color: @text-color;
    font-size: 18px;
    font-weight: bold;
}}

#header-count {{
    color: @ws-inactive;
    font-size: 13px;
    font-weight: normal;
}}

.btn-header {{
    background: @ws-hover-bg;
    color: @text-color;
    border: 1px solid @border-color;
    border-radius: 12px;
    padding: 6px 14px;
    font-size: 13px;
    font-weight: 500;
    transition: all 0.22s ease;
}}

.btn-header:hover {{
    background: @hover-bg;
    border-color: @accent-color;
    color: @accent-color;
    box-shadow: 0 0 12px @ws-glow;
}}

.btn-close {{
    background: @ws-hover-bg;
    color: @text-color;
    border: 1px solid @border-color;
    border-radius: 12px;
    padding: 6px 12px;
    font-size: 13px;
    font-weight: bold;
    transition: all 0.22s ease;
}}

.btn-close:hover {{
    background: rgba(255, 75, 75, 0.22);
    border-color: #ff5555;
    color: #ff5555;
    box-shadow: 0 0 12px rgba(255, 85, 85, 0.4);
}}

#wallpaper-scroll {{
    background: transparent;
    border: none;
}}

#wallpaper-scroll viewport {{
    background: transparent;
}}

flowbox {{
    background: transparent;
}}

flowboxchild {{
    background: transparent;
    padding: 5px;
    border-radius: 14px;
    outline: none;
}}

flowboxchild:selected {{
    background: transparent;
}}

.wallpaper-card {{
    background: @ws-hover-bg;
    border: 1.5px solid @border-color;
    border-radius: 14px;
    padding: 7px;
    transition: all 0.22s ease;
}}

flowboxchild:focus .wallpaper-card,
flowboxchild:hover .wallpaper-card,
.wallpaper-card:hover {{
    background: @hover-bg;
    border-color: @accent-color;
    box-shadow: 0 0 16px @ws-glow;
}}

.wallpaper-card.current-active {{
    border-color: @accent-color;
    box-shadow: 0 0 12px @ws-glow;
}}

.card-label {{
    color: @text-color;
    font-size: 12px;
    font-weight: 500;
    margin-top: 6px;
    padding: 0 4px;
}}

.card-label-current {{
    color: @accent-color;
    font-weight: bold;
}}
"""


# ── Wallpaper Picker Window ───────────────────────────────────────────────────
class WallpaperPicker(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        self.set_title("wallpaper-picker")
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_app_paintable(True)
        self.set_default_size(980, 640)

        # Transparency
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        # Layer Shell configuration (centered overlay)
        if HAS_LAYER_SHELL:
            try:
                gptr = _gptr(self)
                _ls.gtk_layer_init_for_window(gptr)
                _ls.gtk_layer_set_layer(gptr, LAYER_OVERLAY)
                _ls.gtk_layer_set_namespace(gptr, b"wallpaper-picker")
                _ls.gtk_layer_set_keyboard_mode(gptr, KB_EXCLUSIVE)
                _ls.gtk_layer_set_exclusive_zone(gptr, -1)

                # Center on screen: no edges anchored
                _ls.gtk_layer_set_anchor(gptr, EDGE_TOP, False)
                _ls.gtk_layer_set_anchor(gptr, EDGE_BOTTOM, False)
                _ls.gtk_layer_set_anchor(gptr, EDGE_LEFT, False)
                _ls.gtk_layer_set_anchor(gptr, EDGE_RIGHT, False)
            except Exception as e:
                print(f"Layer shell init failed: {e}")
                self.set_position(Gtk.WindowPosition.CENTER)
        else:
            self.set_position(Gtk.WindowPosition.CENTER)

        # CSS styling
        css_prov = Gtk.CssProvider()
        css_prov.load_from_data(get_theme_css().encode())
        Gtk.StyleContext.add_provider_for_screen(
            screen, css_prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        self.wallpapers = find_wallpapers()
        self.current_wall = get_current_wallpaper()

        # Keyboard & Window events
        self.connect("key-press-event", self._on_key)
        self.connect("destroy", lambda *_: self._cleanup_pid())

        self._build_ui()

    def _cleanup_pid(self):
        try:
            if os.path.exists(PID_FILE):
                os.remove(PID_FILE)
        except Exception:
            pass

    def _quit(self):
        self._cleanup_pid()
        Gtk.main_quit()

    def _on_key(self, widget, event):
        if event.keyval == Gdk.KEY_Escape:
            self._quit()
            return True
        return False

    def _on_child_activated(self, flowbox, child):
        if hasattr(child, "wallpaper_path"):
            apply_wallpaper(child.wallpaper_path)
            self._quit()

    def _on_random_clicked(self, button):
        if self.wallpapers:
            chosen = random.choice(self.wallpapers)
            apply_wallpaper(chosen[1])
            self._quit()

    def _build_ui(self):
        outer_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(outer_box)

        main_frame = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        main_frame.set_name("main-frame")
        main_frame.set_size_request(980, 640)
        outer_box.pack_start(main_frame, True, True, 0)

        # Header Row
        header_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)
        main_frame.pack_start(header_box, False, False, 0)

        # Title & Count
        title_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        title_lbl = Gtk.Label(label="🖼️  Выбор обоев")
        title_lbl.set_name("header-title")
        title_box.pack_start(title_lbl, False, False, 0)

        count_lbl = Gtk.Label(label=f"({len(self.wallpapers)} шт.)")
        count_lbl.set_name("header-count")
        title_box.pack_start(count_lbl, False, False, 0)
        header_box.pack_start(title_box, False, False, 0)

        # Spacer
        spacer = Gtk.Box()
        header_box.pack_start(spacer, True, True, 0)

        # Action Buttons
        btn_random = Gtk.Button(label="🎲  Случайные обои")
        btn_random.get_style_context().add_class("btn-header")
        btn_random.connect("clicked", self._on_random_clicked)
        header_box.pack_start(btn_random, False, False, 0)

        btn_close = Gtk.Button(label="✕ Esc")
        btn_close.get_style_context().add_class("btn-close")
        btn_close.connect("clicked", lambda *_: self._quit())
        header_box.pack_start(btn_close, False, False, 0)

        # Scrolled FlowBox
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_name("wallpaper-scroll")
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_vexpand(True)
        scrolled.set_hexpand(True)
        main_frame.pack_start(scrolled, True, True, 0)

        self.flowbox = Gtk.FlowBox()
        self.flowbox.set_valign(Gtk.Align.START)
        self.flowbox.set_halign(Gtk.Align.CENTER)
        self.flowbox.set_max_children_per_line(4)
        self.flowbox.set_min_children_per_line(3)
        self.flowbox.set_row_spacing(14)
        self.flowbox.set_column_spacing(14)
        self.flowbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        self.flowbox.set_activate_on_single_click(True)
        self.flowbox.connect("child-activated", self._on_child_activated)
        scrolled.add(self.flowbox)

        # Populate cards
        initial_focus_child = None

        for fname, fpath, rpath in self.wallpapers:
            child = Gtk.FlowBoxChild()
            child.wallpaper_path = fpath
            is_current = (self.current_wall and rpath == self.current_wall)

            clean_name, ext = os.path.splitext(fname)
            is_animated = ext.lower() in VIDEO_EXTS
            icon_badge = "🎬 " if is_animated else ""

            card_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            card_box.get_style_context().add_class("wallpaper-card")
            if is_current:
                card_box.get_style_context().add_class("current-active")

            # Image thumbnail box (210x130 fixed frame)
            img_container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            img_container.set_size_request(210, 130)
            img_container.set_halign(Gtk.Align.CENTER)
            img_container.set_valign(Gtk.Align.CENTER)

            image = Gtk.Image()
            pixbuf = get_thumbnail(fpath, 210, 130)
            if pixbuf:
                image.set_from_pixbuf(pixbuf)
            img_container.pack_start(image, True, True, 0)
            card_box.pack_start(img_container, False, False, 0)

            # Title label
            display_name = f"✓ {icon_badge}{clean_name}" if is_current else f"{icon_badge}{clean_name}"
            name_lbl = Gtk.Label(label=display_name)
            name_lbl.get_style_context().add_class("card-label")
            if is_current:
                name_lbl.get_style_context().add_class("card-label-current")
            name_lbl.set_ellipsize(Pango.EllipsizeMode.END)
            name_lbl.set_max_width_chars(24)
            name_lbl.set_alignment(0.5, 0.5)
            card_box.pack_start(name_lbl, False, False, 0)

            child.set_tooltip_text(fname)
            child.add(card_box)
            self.flowbox.add(child)

            if is_current:
                initial_focus_child = child

        # Initial keyboard focus
        def set_initial_focus():
            target = initial_focus_child or (self.flowbox.get_children()[0] if self.flowbox.get_children() else None)
            if target:
                self.flowbox.select_child(target)
                target.grab_focus()
            else:
                self.flowbox.grab_focus()

        GLib.idle_add(set_initial_focus)


def main():
    check_single_instance()
    win = WallpaperPicker()
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()
