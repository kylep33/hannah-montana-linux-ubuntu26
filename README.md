# Hannah Montana Linux for Ubuntu 26.04

Turns an Ubuntu (or any Debian-family) install into Hannah Montana Linux: KDE Plasma 6 global theme, pink color schemes, icons, wallpaper, SDDM login screen and Plymouth boot splash, all in one `.deb`.

## Build

```
./build-deb.sh                  # → hannah-montana-theme_26.1.1_all.deb
VERSION=26.1.2 ./build-deb.sh   # bump the version
```

Needs only `dpkg-deb` (present on every Debian/Ubuntu system).

## Install

```
cp hannah-montana-theme_26.1.1_all.deb /tmp/
sudo apt install /tmp/hannah-montana-theme_26.1.1_all.deb
```

1. Apt pulls in KDE Plasma, SDDM, Plymouth and the X server (the SDDM login screen needs it). When asked for a display manager, pick **sddm**.
2. Reboot.
3. On the login screen, pick the **Plasma** session (bottom-left), then log in.

On each user's first Plasma login the theme and panel layout are applied automatically, once. To re-apply: `rm ~/.config/hannah-montana-applied` and log in again.

Remove with `sudo apt remove hannah-montana-theme`.

## Layout

- `root/`: files installed as-is under `/`. Edit here.
- `assets/`: editable source art (`.xcf`, GIMP). Not packaged.
- `build-deb.sh`: builds the package.

## Credits

Theme and artwork from [Hannah Montana Linux 26](https://gitlab.com/DecaCagle/hannahmontanalinux26) by Noah Cagle, itself based on KDE Breeze. Licensed GPLv3+ (see `LICENSE`).
