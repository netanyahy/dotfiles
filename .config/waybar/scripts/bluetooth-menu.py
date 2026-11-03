#!/usr/bin/env python3
"""
Bluetooth popup menu for Waybar.
Transparent glass panel with crisp white border.
Positioned top-center under workspaces via gtk-layer-shell (ctypes).
"""

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')

from gi.repository import Gtk, Gdk, GLib
import subprocess
import threading
import ctypes
import ctypes.util
import os
import signal

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

# Layer shell constants
LAYER_OVERLAY = 3
EDGE_LEFT = 0
EDGE_RIGHT = 1
EDGE_TOP = 2
EDGE_BOTTOM = 3
KB_ON_DEMAND = 1

# ── Helper: get GObject C pointer ────────────────────────────────────────────
_PyCapsule_GetPointer = ctypes.pythonapi.PyCapsule_GetPointer
_PyCapsule_GetPointer.restype = ctypes.c_void_p
_PyCapsule_GetPointer.argtypes = [ctypes.py_object, ctypes.c_char_p]

def _gptr(gobject):
    return _PyCapsule_GetPointer(gobject.__gpointer__, None)


# ── Bluetooth helpers ─────────────────────────────────────────────────────────
def run_cmd(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return r.stdout.strip().split('\n') if r.stdout.strip() else []
    except Exception:
        return []


def get_bt_power():
    for l in run_cmd("bluetoothctl show"):
        if "Powered:" in l:
            return "yes" in l
    return False


def get_connected_devices():
    devices = []
    for l in run_cmd("bluetoothctl devices Connected"):
        p = l.split(None, 2)
        if len(p) >= 3 and p[0] == "Device":
            devices.append((p[1], p[2]))
    return devices


def get_paired_devices():
    conn_macs = {d[0] for d in get_connected_devices()}
    devices = []
    for l in run_cmd("bluetoothctl devices Paired"):
        p = l.split(None, 2)
        if len(p) >= 3 and p[0] == "Device" and p[1] not in conn_macs:
            devices.append((p[1], p[2]))
    return devices


def scan_devices():
    run_cmd("bluetoothctl --timeout 5 scan on")
    conn = {d[0] for d in get_connected_devices()}
    paired = {d[0] for d in get_paired_devices()}
    devices = []
    for l in run_cmd("bluetoothctl devices"):
        p = l.split(None, 2)
        if len(p) >= 3 and p[0] == "Device":
            mac, name = p[1], p[2]
            if mac not in conn and mac not in paired and name != mac:
                devices.append((mac, name))
    return devices


def bt_connect(mac):
    run_cmd(f"bluetoothctl connect {mac}")

def bt_disconnect(mac):
    run_cmd(f"bluetoothctl disconnect {mac}")

def bt_remove(mac):
    run_cmd(f"bluetoothctl disconnect {mac}")
    run_cmd(f"bluetoothctl remove {mac}")

def bt_pair_connect(mac):
    run_cmd(f"bluetoothctl pair {mac}")
    run_cmd(f"bluetoothctl trust {mac}")
    run_cmd(f"bluetoothctl connect {mac}")

def bt_power_on():
    run_cmd("bluetoothctl power on")

def bt_power_off():
    run_cmd("bluetoothctl power off")


# ── CSS ───────────────────────────────────────────────────────────────────────
def get_theme_css():
    bt_theme = os.path.expanduser("~/.config/waybar/themes/bluetooth_theme.css")
    curr_theme = os.path.expanduser("~/.config/waybar/themes/current.css")
    theme_file = None
    if os.path.isfile(bt_theme):
        theme_file = bt_theme
    elif os.path.isfile(curr_theme):
        theme_file = curr_theme

    import_line = f'@import "{theme_file}";\n' if theme_file else ""

    return f"""
/* Fallback theme variables */
@define-color bg-color rgba(18, 18, 22, 0.85);
@define-color border-color rgba(255, 255, 255, 0.2);
@define-color text-color #ffffff;
@define-color accent-color #ffffff;
@define-color ws-inactive rgba(255, 255, 255, 0.45);
@define-color ws-hover-bg rgba(255, 255, 255, 0.12);
@define-color ws-hover-fg #ffffff;
@define-color ws-active-bg #ffffff;
@define-color ws-active-fg #000000;
@define-color ws-shadow rgba(255, 255, 255, 0.5);
@define-color ws-glow rgba(255, 255, 255, 0.2);

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
    border: 1px solid @accent-color;
    border-radius: 18px;
    box-shadow: 0 4px 20px @ws-glow;
    padding: 16px;
    animation: fadeIn 0.3s ease-out;
}}

#title-label {{
    color: @text-color;
    font-size: 15px;
    font-weight: bold;
    padding: 2px 0 4px 2px;
}}

#section-label {{
    color: @ws-inactive;
    font-size: 10px;
    font-weight: bold;
    letter-spacing: 2px;
    margin-top: 10px;
    margin-bottom: 4px;
    padding: 0 4px;
}}

/* ── Device buttons ───────────────────────────────────── */
.device-btn {{
    background: @ws-hover-bg;
    border: 1px solid @border-color;
    border-radius: 12px;
    color: @text-color;
    padding: 11px 14px;
    margin: 3px 0;
    font-size: 13px;
    transition: all 0.3s ease;
}}

.device-btn:hover {{
    background: @ws-hover-bg;
    border-color: @accent-color;
}}

.device-btn:active {{
    background: @ws-active-bg;
    color: @ws-active-fg;
    transition: all 0.08s ease;
}}

.connected {{
    border-left: 3px solid @accent-color;
}}
.connected:hover {{
    border-left-color: @accent-color;
}}

.paired {{
    border-left: 3px solid @border-color;
}}
.paired:hover {{
    border-left-color: @accent-color;
}}

.discovered {{
    border-left: 3px solid @accent-color;
}}
.discovered:hover {{
    border-left-color: @accent-color;
}}

/* ── Inline action buttons (disconnect / remove) ─────── */
.act-btn {{
    background: @ws-hover-bg;
    border: 1px solid @border-color;
    border-radius: 10px;
    color: @text-color;
    padding: 8px 10px;
    margin: 2px 2px;
    font-size: 13px;
    transition: all 0.25s ease;
}}
.act-btn:hover {{
    background: @ws-active-bg;
    color: @ws-active-fg;
}}

.danger:hover {{
    background: rgba(240,70,70,0.22);
    border-color: rgba(240,70,70,0.35);
    color: #ff9090;
}}

/* ── Scan button ──────────────────────────────────────── */
.scan-btn {{
    background: @ws-hover-bg;
    border: 1px dashed @border-color;
    border-radius: 12px;
    color: @text-color;
    padding: 11px 14px;
    margin: 3px 0;
    font-size: 13px;
    transition: all 0.3s ease;
}}
.scan-btn:hover {{
    border-color: @accent-color;
    color: @accent-color;
}}

/* ── Power off ────────────────────────────────────────── */
.power-btn {{
    background: rgba(255,55,55,0.08);
    border: 1px solid rgba(255,55,55,0.18);
    border-radius: 12px;
    color: rgba(255,140,140,0.85);
    padding: 11px 14px;
    margin-top: 6px;
    font-size: 13px;
    transition: all 0.3s ease;
}}
.power-btn:hover {{
    background: rgba(255,55,55,0.22);
    border-color: rgba(255,55,55,0.38);
    color: #ff9999;
}}

/* ── Misc ─────────────────────────────────────────────── */
.sep {{
    background: @border-color;
    min-height: 1px;
    margin: 8px 0;
}}

#status-label {{
    color: @ws-inactive;
    font-size: 11px;
    padding: 4px 4px 2px;
    font-style: italic;
}}

.back-btn {{
    background: transparent;
    border: none;
    color: @ws-inactive;
    padding: 6px 10px;
    font-size: 13px;
    transition: all 0.25s ease;
}}
.back-btn:hover {{
    color: @text-color;
}}
"""


class BluetoothMenu(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        self.set_title("bt-popup")
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_default_size(330, -1)
        self.set_app_paintable(True)

        # RGBA visual for transparency
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        # ── Layer shell BEFORE realize ──
        if HAS_LAYER_SHELL:
            try:
                gptr = _gptr(self)
                _ls.gtk_layer_init_for_window(gptr)
                _ls.gtk_layer_set_layer(gptr, LAYER_OVERLAY)
                _ls.gtk_layer_set_namespace(gptr, b"bt-popup")
                _ls.gtk_layer_set_keyboard_mode(gptr, KB_ON_DEMAND)
                _ls.gtk_layer_set_exclusive_zone(gptr, -1)

                # Anchor: top-center (under workspaces panel)
                _ls.gtk_layer_set_anchor(gptr, EDGE_TOP, True)
                _ls.gtk_layer_set_anchor(gptr, EDGE_BOTTOM, False)
                _ls.gtk_layer_set_anchor(gptr, EDGE_LEFT, False)
                _ls.gtk_layer_set_anchor(gptr, EDGE_RIGHT, False)

                _ls.gtk_layer_set_margin(gptr, EDGE_TOP, 62)
                _ls.gtk_layer_set_margin(gptr, EDGE_BOTTOM, 0)
                _ls.gtk_layer_set_margin(gptr, EDGE_LEFT, 0)
                _ls.gtk_layer_set_margin(gptr, EDGE_RIGHT, 0)

                self._layer_ok = True
            except Exception as e:
                print(f"Layer shell init failed: {e}")
                self._layer_ok = False
        else:
            self._layer_ok = False

        # Load CSS
        css_prov = Gtk.CssProvider()
        css_prov.load_from_data(get_theme_css().encode())
        Gtk.StyleContext.add_provider_for_screen(
            screen, css_prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Events
        self.connect('key-press-event', self._on_key)
        self.connect('focus-out-event', lambda *_: self._quit())

        # Build UI
        self._build()

    # ── helpers ───────────────────────────────────────────────────────────────
    def _on_key(self, w, ev):
        if ev.keyval == Gdk.KEY_Escape:
            self._quit()

    def _quit(self):
        Gtk.main_quit()

    def _clear(self):
        for ch in self.content.get_children():
            self.content.remove(ch)

    def _add_section(self, text):
        lbl = Gtk.Label(label=text)
        lbl.set_name("section-label")
        lbl.set_halign(Gtk.Align.START)
        self.content.pack_start(lbl, False, False, 0)

    def _add_sep(self):
        s = Gtk.Separator()
        s.get_style_context().add_class("sep")
        self.content.pack_start(s, False, False, 0)

    def _set_status(self, text):
        self.status.set_text(text)

    def _threaded(self, fn, *args, callback=None):
        """Run fn in thread, then call callback on main thread."""
        def _run():
            fn(*args)
            if callback:
                GLib.idle_add(callback)
        threading.Thread(target=_run, daemon=True).start()

    # ── Build ─────────────────────────────────────────────────────────────────
    def _build(self):
        # Outer alignment: centered horizontally, aligned to top
        align = Gtk.Alignment(xalign=0.5, yalign=0.0, xscale=0, yscale=0)
        self.add(align)

        frame = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        frame.set_name("main-frame")
        frame.set_size_request(330, -1)
        align.add(frame)

        # Title row
        title = Gtk.Label(label="󰂯  Bluetooth")
        title.set_name("title-label")
        title.set_halign(Gtk.Align.START)
        frame.pack_start(title, False, False, 0)

        # Status
        self.status = Gtk.Label()
        self.status.set_name("status-label")
        self.status.set_halign(Gtk.Align.START)
        frame.pack_start(self.status, False, False, 0)

        # Content (swappable)
        self.content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        frame.pack_start(self.content, False, False, 0)

        if get_bt_power():
            self._view_main()
        else:
            self._view_off()

    # ── Views ─────────────────────────────────────────────────────────────────
    def _view_off(self):
        self._clear()
        self._set_status("Bluetooth выключен")

        btn = Gtk.Button(label="󰂯  Включить Bluetooth")
        btn.get_style_context().add_class("scan-btn")
        btn.connect("clicked", lambda b: (
            b.set_label("⏳  Включаю..."),
            b.set_sensitive(False),
            self._threaded(bt_power_on, callback=self._view_main),
        ))
        self.content.pack_start(btn, False, False, 6)
        self.content.show_all()

    def _view_main(self):
        self._clear()

        connected = get_connected_devices()
        paired = get_paired_devices()

        # ── Connected ──
        if connected:
            self._add_section("ПОДКЛЮЧЕНО")
            for mac, name in connected:
                row = Gtk.Box(spacing=5)

                btn = Gtk.Button(label=f"󰂱  {name}")
                ctx = btn.get_style_context()
                ctx.add_class("device-btn")
                ctx.add_class("connected")
                btn.set_hexpand(True)
                row.pack_start(btn, True, True, 0)

                dc = Gtk.Button(label="󰂲")
                dc.get_style_context().add_class("act-btn")
                dc.set_tooltip_text("Отключить")
                dc.connect("clicked", lambda b, m=mac, n=name: (
                    self._set_status(f"Отключение {n}..."),
                    self._threaded(bt_disconnect, m, callback=self._view_main),
                ))
                row.pack_start(dc, False, False, 0)

                rm = Gtk.Button(label="󰆴")
                ctx2 = rm.get_style_context()
                ctx2.add_class("act-btn")
                ctx2.add_class("danger")
                rm.set_tooltip_text("Забыть")
                rm.connect("clicked", lambda b, m=mac, n=name: (
                    self._set_status(f"Удаление {n}..."),
                    self._threaded(bt_remove, m, callback=self._view_main),
                ))
                row.pack_start(rm, False, False, 0)

                self.content.pack_start(row, False, False, 2)

            self._set_status(f"Подключено: {len(connected)}")
        else:
            self._set_status("Нет подключённых устройств")

        # ── Paired ──
        if paired:
            self._add_sep()
            self._add_section("СОПРЯЖЕНО")
            for mac, name in paired:
                btn = Gtk.Button(label=f"󰂰  {name}")
                ctx = btn.get_style_context()
                ctx.add_class("device-btn")
                ctx.add_class("paired")
                btn.connect("clicked", lambda b, m=mac, n=name: (
                    self._set_status(f"Подключение к {n}..."),
                    b.set_sensitive(False),
                    self._threaded(bt_connect, m, callback=self._view_main),
                ))
                self.content.pack_start(btn, False, False, 2)

        # ── Actions ──
        self._add_sep()

        scan = Gtk.Button(label="󰂰  Сканировать устройства")
        scan.get_style_context().add_class("scan-btn")
        scan.connect("clicked", self._on_scan)
        self.content.pack_start(scan, False, False, 2)

        poff = Gtk.Button(label="󰂲  Выключить Bluetooth")
        poff.get_style_context().add_class("power-btn")
        poff.connect("clicked", lambda b: (bt_power_off(), self._view_off()))
        self.content.pack_start(poff, False, False, 2)

        self.content.show_all()

    def _on_scan(self, btn):
        btn.set_label("⏳  Сканирование…")
        btn.set_sensitive(False)
        self._set_status("Поиск устройств (5 сек)…")
        def _bg_scan():
            devs = scan_devices()
            GLib.idle_add(lambda: self._view_scan(devs))
        threading.Thread(target=_bg_scan, daemon=True).start()

    def _view_scan(self, devices):
        self._clear()

        # Back
        back = Gtk.Button(label="←  Назад")
        back.get_style_context().add_class("back-btn")
        back.set_halign(Gtk.Align.START)
        back.connect("clicked", lambda b: self._view_main())
        self.content.pack_start(back, False, False, 0)

        self._add_sep()

        if devices:
            self._add_section("НАЙДЕННЫЕ УСТРОЙСТВА")
            self._set_status(f"Найдено: {len(devices)}")
            for mac, name in devices:
                btn = Gtk.Button(label=f"󰂱  {name}")
                ctx = btn.get_style_context()
                ctx.add_class("device-btn")
                ctx.add_class("discovered")
                btn.connect("clicked", lambda b, m=mac, n=name: (
                    self._set_status(f"Сопряжение с {n}…"),
                    b.set_sensitive(False),
                    self._threaded(bt_pair_connect, m, callback=self._view_main),
                ))
                self.content.pack_start(btn, False, False, 2)
        else:
            self._set_status("Устройства не найдены")
            lbl = Gtk.Label(label="Нет новых устройств поблизости")
            lbl.set_name("status-label")
            self.content.pack_start(lbl, False, False, 12)

        # Re-scan
        scan = Gtk.Button(label="󰂰  Сканировать снова")
        scan.get_style_context().add_class("scan-btn")
        scan.connect("clicked", self._on_scan)
        self.content.pack_start(scan, False, False, 2)

        self.content.show_all()


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    # Toggle: kill existing instance
    pid_file = f"{os.environ.get('XDG_RUNTIME_DIR', '/tmp')}/bt-menu-popup.pid"
    if os.path.exists(pid_file):
        try:
            old_pid = int(open(pid_file).read().strip())
            os.kill(old_pid, signal.SIGTERM)
            import time; time.sleep(0.15)
            # If we killed successfully, this is a toggle-off — exit
            os.unlink(pid_file)
            return
        except ProcessLookupError:
            pass
        except (ValueError, PermissionError):
            pass

    with open(pid_file, 'w') as f:
        f.write(str(os.getpid()))

    win = BluetoothMenu()
    win.show_all()

    # Auto-close after 30s
    GLib.timeout_add_seconds(30, lambda: (Gtk.main_quit(), False)[1])

    Gtk.main()

    try:
        os.unlink(pid_file)
    except OSError:
        pass


if __name__ == "__main__":
    main()
