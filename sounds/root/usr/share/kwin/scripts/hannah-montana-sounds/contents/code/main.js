// KWin scripts can't play audio. The ping is only a marker: the hannah-montana-sounds
// helper watches the bus for this path, so it needs no D-Bus service of its own.
workspace.windowRemoved.connect(function (window) {
    if (window.normalWindow) {
        callDBus("org.freedesktop.DBus", "/org/hml/WindowClosed", "org.freedesktop.DBus.Peer", "Ping");
    }
});
