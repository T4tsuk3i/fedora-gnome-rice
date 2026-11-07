# Fedora 45 — GNOME 51 macOS-style rice

A complete snapshot of this Fedora Workstation GNOME setup: **WhiteSur** shell/GTK, **MacTahoe (macOS 26 / Tahoe)** icons, **Kvantum MacTahoe** for Dolphin, a wallpaper-tinted dynamic top bar, Ghostty + fastfetch, and the WhiteSur GDM theme.

Tested on Fedora 45, GNOME Shell 51.1, 1920×1080 @ 1×.

## What's in the look

| Part | What it is |
|---|---|
| Shell | WhiteSur-Light (`themes/WhiteSur-Light/gnome-shell/gnome-shell.css`, customised) |
| GTK / libadwaita | WhiteSur-Light |
| Icons | MacTahoe-light (macOS Tahoe 26), inherits `WhiteSur,Adwaita,breeze,hicolor` |
| Cursor | WhiteSur-cursors |
| Qt / Dolphin | Kvantum `MacTahoe` + `qt6ct` (opaque, X11 window buttons) |
| Terminal | Ghostty + `Typecraft Mocha` theme |
| Top bar | globalmenu, apps-menu, just-perfection, dash-to-dock, blur-my-shell |
| Dynamic tint | `island-tint` samples the top of the wallpaper and rewrites the panel tint |
| GDM | WhiteSur GDM theme with a custom login wallpaper |
| Wallpaper | `wallpapers/background.jpg` |
| Fastfetch | custom layout, keeps the random image bank concept |

## Custom bits

- **Dynamic top bar** — `home/.local/bin/island-tint` samples the top 6% of the current wallpaper and writes an `AUTO-TINT` block into the shell theme CSS. A systemd path/service re-runs it whenever `picture-uri-dark` changes. That's why the bar changes colour with the background.
- **Super opens the app grid** — `extensions/start-app-grid@local` overrides `Overview.toggle()` to show the Applications grid instead of the window overview. Needs one logout/login to load.
- **Dolphin + Dash to Dock trash** — Dash to Dock hardcodes Nautilus's D-Bus service. `home/.local/bin/nautilus-trash-service` is a small shim that owns `org.gnome.Nautilus` and implements `EmptyTrash` with `gio trash --empty`, so the dock trash works with Dolphin. Enabled as a user service.
- **Dolphin macOS look** — `home/.local/share/applications/org.kde.dolphin.desktop` launches Dolphin with `QT_QPA_PLATFORM=xcb QT_QPA_PLATFORMTHEME=qt6ct QT_STYLE_OVERRIDE=kvantum`; `home/.config/qt6ct`, `Kvantum`, `kdeglobals` and `MacTahoeLight.colors` make it match the GTK theme.
- **Lock-screen arrow** — the custom shell CSS contains a compact override for the login/next button, so the arrow isn't oversized.
- **Panel text** — no heavy shadows, smaller panel font, transparent clock highlight.

## Install

> This is a personal dotfiles repo. `install.sh` copies configs into your home and runs `dconf load /org/gnome/`, which overwrites your GNOME settings. Read it first.

```bash
git clone https://github.com/T4tsuk3i/fedora-gnome-rice.git
cd fedora-gnome-rice
./install.sh
```

Then log out and back in (the new extensions and theme need a fresh session).

### Optional: themed GDM login screen

```bash
sudo bash themes/gdm/install.sh
```

This builds the WhiteSur GDM theme and installs a path/service that re-applies it if a `gnome-shell` update resets the gresource.

## Notes

- Requires internet for the theme/extension clones (`vinceliuice` repos).
- Extensions in `extensions/` are copied to `~/.local/share/gnome-shell/extensions`; the rest come from Fedora packages or extensions.gnome.org (see `packages.txt` and `extensions/enabled.txt`).
- The fastfetch random image bank (`~/Pictures/ghostty/bank`) is not bundled — it's personal wallpaper art. The config still works; point it at your own bank.
- Nautilus is intentionally not used; Dolphin is the default file manager.
- If you use the GDM theme, run the GDM script only from a GNOME session.

## Credits

- [WhiteSur GTK theme](https://github.com/vinceliuice/WhiteSur-gtk-theme) / [icons](https://github.com/vinceliuice/WhiteSur-icon-theme) / [cursors](https://github.com/vinceliuice/WhiteSur-cursors) — vinceliuice
- [MacTahoe icons](https://github.com/vinceliuice/MacTahoe-icon-theme) and [MacTahoe KDE](https://github.com/vinceliuice/MacTahoe-kde) — vinceliuice
- [Global Menu for GNOME](https://github.com/ShiroOSL/global-menu-for-gnome) — ShiroOSL
- [Just Perfection](https://gitlab.gnome.org/jrahmatzadeh/just-perfection), [Blur My Shell](https://github.com/aunetx/blur-my-shell), [Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/), [App Grid Tuner](https://codeberg.org/m-lab/app-grid-tuner)
