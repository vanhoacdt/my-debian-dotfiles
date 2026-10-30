#!/bin/bash
REPO_DIR="$HOME/my-debian-dotfiles"

mkdir -p "$REPO_DIR/dconf/parts" "$REPO_DIR/apt" "$REPO_DIR/bin/ai" "$REPO_DIR/configs"

echo "1. Đang xuất cấu hình hệ thống & phím tắt (dconf)..."
dconf dump / > "$REPO_DIR/dconf/full_gnome.dconf"

# Tách thành các phần nhỏ để dễ quản lý
PARTS="$REPO_DIR/dconf/parts"
rm -f "$PARTS"/*.dconf 2>/dev/null || true
awk '
BEGIN { file = "'"$PARTS"'/00-misc.dconf" }
/^\[[^\]]+\]/ {
  section = $0
  if (section ~ /org\/gnome\/desktop\/wm/) {
    file = "'"$PARTS"'/02-keybindings.dconf"
  } else if (section ~ /org\/gnome\/desktop/) {
    file = "'"$PARTS"'/01-desktop.dconf"
  } else if (section ~ /org\/gnome\/(mutter|settings-daemon)/) {
    file = "'"$PARTS"'/02-keybindings.dconf"
  } else if (section ~ /org\/gnome\/shell/) {
    file = "'"$PARTS"'/03-shell-extensions.dconf"
  } else if (section ~ /org\/gnome\/(evolution|evolution-data-server)/) {
    file = "'"$PARTS"'/04-evolution.dconf"
  } else if (section ~ /org\/gnome\/(nautilus|rhythmbox|terminal|Totem|cheese|control-center|gnome-system-monitor|file-roller|evince|baobab|simple-scan|software)/) {
    file = "'"$PARTS"'/05-apps.dconf"
  } else {
    file = "'"$PARTS"'/00-misc.dconf"
  }
}
{ print > file }
' "$REPO_DIR/dconf/full_gnome.dconf"
echo "→ Đã tách dconf thành các phần nhỏ"

echo "2. Đang sao lưu danh sách phần mềm APT..."
apt-mark showmanual > "$REPO_DIR/apt/manual_packages.list"

echo "3. Đang sao lưu script cá nhân trong ~/.local/bin..."
cp ~/.local/bin/*.sh "$REPO_DIR/bin/" 2>/dev/null || true
cp -r ~/.local/bin/ai/* "$REPO_DIR/bin/ai/" 2>/dev/null || true

echo "4. Đang sao lưu dotfiles..."
cp ~/.bashrc ~/.profile ~/.gitconfig "$REPO_DIR/configs/" 2>/dev/null || true

echo "5. Đang commit và đẩy lên GitHub..."
cd "$REPO_DIR" || exit
git add .
git commit -m "Backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push -u origin main

echo "Hoàn tất sao lưu lên GitHub!"
