#!/usr/bin/env bash
# Fedora 45 / GNOME 51 macOS-style rice installer.
# Run as your normal user (not root). It uses sudo for packages only.
set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
[[ $EUID -ne 0 ]] || { echo "Run this as your user, not root." >&2; exit 1; }

echo "==> packages"
grep -v '^#' "$REPO/packages.txt" | xargs sudo dnf install -y

echo "==> themes"
mkdir -p "$HOME/src"
clone() { [[ -d "$HOME/src/$1" ]] || git clone --depth 1 "$2" "$HOME/src/$1"; }
clone WhiteSur-gtk-theme  https://github.com/vinceliuice/WhiteSur-gtk-theme.git
clone WhiteSur-icon-theme https://github.com/vinceliuice/WhiteSur-icon-theme.git
clone WhiteSur-cursors    https://github.com/vinceliuice/WhiteSur-cursors.git
clone MacTahoe-icon-theme https://github.com/vinceliuice/MacTahoe-icon-theme.git
clone MacTahoe-kde        https://github.com/vinceliuice/MacTahoe-kde.git

(cd "$HOME/src/WhiteSur-gtk-theme"  && ./install.sh -c light -o normal -l)
(cd "$HOME/src/WhiteSur-icon-theme" && ./install.sh)
(cd "$HOME/src/WhiteSur-cursors"    && ./install.sh)
(cd "$HOME/src/MacTahoe-icon-theme" && ./install.sh -d "$HOME/.local/share/icons")

# our customised shell CSS + Show Apps icon
cp "$REPO/themes/WhiteSur-Light/gnome-shell/gnome-shell.css" \
   "$HOME/.themes/WhiteSur-Light/gnome-shell/gnome-shell.css"
cp "$REPO/themes/WhiteSur-Light/gnome-shell/assets/view-app-grid.svg" \
   "$HOME/.themes/WhiteSur-Light/gnome-shell/assets/view-app-grid.svg"

# macOS icons first, then WhiteSur/Adwaita/Breeze for missing icons
for f in "$HOME"/.local/share/icons/MacTahoe*/index.theme; do
  sed -i 's/^Inherits=.*/Inherits=WhiteSur,Adwaita,breeze,hicolor/' "$f"
done
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/MacTahoe-light" 2>/dev/null || true

# Kvantum MacTahoe theme for Dolphin/Qt6
mkdir -p "$HOME/.config/Kvantum"
cp -a "$REPO/home/.config/Kvantum/." "$HOME/.config/Kvantum/"

echo "==> configs"
cp -a "$REPO/home/." "$HOME/"
chmod +x "$HOME/.local/bin/island-tint" \
         "$HOME/.local/bin/daily-wallpaper" \
         "$HOME/.local/bin/nautilus-trash-service"

# make copied units/scripts portable
for d in "$HOME/.config/systemd/user" "$HOME/.local/share/dbus-1/services" \
         "$HOME/.config/qt6ct" "$HOME/.local/bin"; do
  grep -rIl '/home/tatsuya' "$d" 2>/dev/null | while read -r f; do
    sed -i "s|/home/tatsuya|$HOME|g" "$f"
  done
done

cp "$REPO/wallpapers/background.jpg" "$HOME/.config/background"

echo "==> extensions"
mkdir -p "$HOME/.local/share/gnome-shell/extensions"
for e in "$REPO"/extensions/*/; do
  uuid=$(basename "$e")
  [[ "$uuid" == "enabled.txt" ]] && continue
  rm -rf "$HOME/.local/share/gnome-shell/extensions/$uuid"
  cp -a "$e" "$HOME/.local/share/gnome-shell/extensions/$uuid"
done

echo "==> defaults"
xdg-mime default org.kde.dolphin.desktop inode/directory
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

echo "==> dconf (this overwrites /org/gnome/ settings)"
sed "s|/home/tatsuya|$HOME|g" "$REPO/dconf/gnome.ini" | dconf load /org/gnome/

echo "==> user services"
systemctl --user daemon-reload
systemctl --user enable --now island-tint.service nautilus-trash-service.service 2>/dev/null || true
systemctl --user enable --now daily-wallpaper.timer 2>/dev/null || true

cat <<EOF

==> done

Log out and back in so the shell theme, icons, Qt theme and the
start-app-grid extension load.

Optional themed GDM login screen:
    sudo bash "$REPO/themes/gdm/install.sh"

EOF
