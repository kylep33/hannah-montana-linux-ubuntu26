#!/bin/bash
# Optional add-on: package sounds/root/ plus the clips in transitions/ into hannah-montana-sounds_<version>_all.deb
# Local builds only: the clips are not ours to redistribute, so keep this .deb to yourself.
set -euo pipefail
cd "$(dirname "$0")"

VERSION=${VERSION:-26.1.1}
OUT=hannah-montana-sounds_${VERSION}_all.deb
PKG=$(mktemp -d)
trap 'rm -rf "$PKG"' EXIT

cp -a sounds/root/. "$PKG/"
for pool in upbeat-long upbeat-short somber-long somber-short really-short; do
    ls transitions/$pool/*.wav >/dev/null || { echo "pool $pool has no clips" >&2; exit 1; }
    cp -r transitions/$pool "$PKG/usr/share/hannah-montana-sounds/"
done
mkdir -p "$PKG/DEBIAN"
chmod -R u=rwX,go=rX "$PKG"
chmod 755 "$PKG/usr/libexec/hannah-montana-sounds"
(cd "$PKG" && find etc -type f | sed 's|^|/|') > "$PKG/DEBIAN/conffiles"

cat > "$PKG/DEBIAN/control" <<EOF
Package: hannah-montana-sounds
Version: $VERSION
Architecture: all
Section: sound
Priority: optional
Maintainer: kylep33 <kyleapereira33@gmail.com>
Depends: kde-plasma-desktop, pipewire-bin, dbus-bin
Recommends: hannah-montana-theme
Installed-Size: $(du -sk "$PKG/usr" "$PKG/etc" | awk '{s+=$1} END {print s}')
Description: Optional transition sounds for Hannah Montana Linux
 Plays randomly chosen transition clips for desktop events and window closes.
EOF

# Per-user links would dangle once the clips are gone.
cat > "$PKG/DEBIAN/prerm" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = remove ]; then
    rm -rf /home/*/.local/share/sounds/hannah-montana
fi
EOF
chmod 755 "$PKG/DEBIAN/prerm"

dpkg-deb --root-owner-group -Zxz --build "$PKG" "$OUT"

LIST=$(dpkg-deb -c "$OUT")
for f in usr/libexec/hannah-montana-sounds \
         usr/share/hannah-montana-sounds/index.theme \
         usr/share/kwin/scripts/hannah-montana-sounds/metadata.json \
         etc/xdg/autostart/hannah-montana-sounds.desktop; do
    grep -q " \./$f\$" <<<"$LIST" || { echo "missing $f in $OUT" >&2; exit 1; }
done
echo "built $OUT"
