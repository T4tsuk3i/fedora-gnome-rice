#!/bin/bash
# Run with: sudo bash ~/.local/share/whitesur-gdm-setup/install.sh
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=${SUDO_USER:+$(getent passwd "$SUDO_USER" | cut -d: -f6)}/src/WhiteSur-gtk-theme
DEST=/usr/local/share/whitesur-gdm
mkdir -p "$DEST"
rm -rf "$DEST/WhiteSur-gtk-theme"; cp -r "$REPO" "$DEST/WhiteSur-gtk-theme"
cp "$HERE/login-wallpaper.png" "$DEST/"
install -m755 "$HERE/whitesur-gdm-apply" /usr/local/sbin/whitesur-gdm-apply
install -m644 "$HERE/whitesur-gdm.service" /etc/systemd/system/
install -m644 "$HERE/whitesur-gdm.path" /etc/systemd/system/
restorecon -R "$DEST" /usr/local/sbin/whitesur-gdm-apply 2>/dev/null || true
systemctl daemon-reload
/usr/local/sbin/whitesur-gdm-apply
systemctl enable --now whitesur-gdm.path whitesur-gdm.service
echo "Done. Log out or reboot to see the new login screen."
