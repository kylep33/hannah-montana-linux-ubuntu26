#!/bin/bash
# Package root/ (laid out exactly as installed under /) into hannah-montana-theme_<version>_all.deb
# Usage: ./build-deb.sh            (VERSION=26.1.2 ./build-deb.sh to bump)
set -euo pipefail
cd "$(dirname "$0")"

VERSION=${VERSION:-26.1.1}
OUT=hannah-montana-theme_${VERSION}_all.deb
PKG=$(mktemp -d)
trap 'rm -rf "$PKG"' EXIT

cp -a root/. "$PKG/"
mkdir -p "$PKG/DEBIAN"
chmod -R u=rwX,go=rX "$PKG"
(cd "$PKG" && find etc -type f | sed 's|^|/|') > "$PKG/DEBIAN/conffiles"

cat > "$PKG/DEBIAN/control" <<EOF
Package: hannah-montana-theme
Version: $VERSION
Architecture: all
Section: x11
Priority: optional
Maintainer: kylep33 <kyleapereira33@gmail.com>
Depends: kde-plasma-desktop, sddm, plymouth, xserver-xorg
Installed-Size: $(du -sk "$PKG/usr" "$PKG/etc" | awk '{s+=$1} END {print s}')
Description: Hannah Montana Linux look for KDE Plasma 6
 Global theme, Plasma theme, colors, icons, wallpaper, SDDM login theme
 and Plymouth boot splash from Hannah Montana Linux 26.
EOF

PLY=/usr/share/plymouth/themes/hannah-montana/hannah-montana.plymouth
cat > "$PKG/DEBIAN/postinst" <<EOF
#!/bin/sh
set -e
if [ "\$1" = configure ]; then
    # priority 200 beats Ubuntu's bgrt (110); removal falls back automatically
    update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth $PLY 200
    if command -v update-initramfs >/dev/null; then update-initramfs -u || echo "warning: update-initramfs failed, boot splash unchanged" >&2; fi
fi
EOF
cat > "$PKG/DEBIAN/prerm" <<EOF
#!/bin/sh
set -e
if [ "\$1" = remove ]; then
    update-alternatives --remove default.plymouth $PLY
    if command -v update-initramfs >/dev/null; then update-initramfs -u || true; fi
fi
EOF
chmod 755 "$PKG/DEBIAN/postinst" "$PKG/DEBIAN/prerm"

dpkg-deb --root-owner-group -Zxz --build "$PKG" "$OUT"

# self-check: the pieces the look-and-feel package points at made it in
LIST=$(dpkg-deb -c "$OUT")
for f in usr/share/plasma/look-and-feel/org.hml.desktop/metadata.json \
         usr/share/wallpapers/HannahMontanaTheme/metadata.json \
         usr/share/color-schemes/PrettyPink.colors \
         usr/share/icons/HannahMontana/index.theme \
         usr/share/sddm/themes/hannah-montana-sddm/Main.qml \
         usr/share/plymouth/themes/hannah-montana/hannah-montana.plymouth \
         etc/skel/.config/kdeglobals \
         etc/xdg/autostart/hannah-montana-first-login.desktop \
         usr/libexec/hannah-montana-first-login; do
    grep -q " \./$f\$" <<<"$LIST" || { echo "missing $f in $OUT" >&2; exit 1; }
done
echo "built $OUT"
