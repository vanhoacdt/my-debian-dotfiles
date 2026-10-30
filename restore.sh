#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Bắt đầu khôi phục Debian GNOME Dotfiles ==="

echo "1. Cài đặt công cụ cần thiết..."
sudo apt update
sudo apt install -y wmctrl dconf-cli git

echo "2. Khôi phục giao diện & phím tắt GNOME..."
DCONF_DIR="$DIR/dconf/parts"
if [ -d "$DCONF_DIR" ] && ls "$DCONF_DIR"/*.dconf >/dev/null 2>&1; then
    for f in "$DCONF_DIR"/*.dconf; do
        echo "  → Load $(basename "$f")"
        dconf load / < "$f"
    done
    echo "→ Đã load toàn bộ dconf parts"
elif [ -f "$DIR/dconf/full_gnome.dconf" ]; then
    dconf load / < "$DIR/dconf/full_gnome.dconf"
    echo "→ Đã load full_gnome.dconf"
else
    echo "→ Không tìm thấy file dconf"
fi

echo "3. Khôi phục scripts cá nhân..."
mkdir -p "$HOME/.local/bin/ai"
cp "$DIR/bin/"*.sh "$HOME/.local/bin/" 2>/dev/null || true
cp -r "$DIR/bin/ai/"* "$HOME/.local/bin/ai/" 2>/dev/null || true
chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
chmod +x "$HOME/.local/bin/ai/"*.sh 2>/dev/null || true
echo "→ Đã copy scripts vào ~/.local/bin"

echo "4. Khôi phục dotfiles..."
cp "$DIR/configs/.bashrc" "$HOME/" 2>/dev/null || true
cp "$DIR/configs/.profile" "$HOME/" 2>/dev/null || true
cp "$DIR/configs/.gitconfig" "$HOME/" 2>/dev/null || true
echo "→ Đã khôi phục .bashrc, .profile, .gitconfig"

echo "5. Cài đặt lại các gói APT (có xác nhận)..."
if [ -f "$DIR/apt/manual_packages.list" ]; then
    echo "Danh sách gói sẽ được cài:"
    cat "$DIR/apt/manual_packages.list"
    echo
    read -p "Bạn có muốn cài tất cả các gói trên không? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo xargs -a "$DIR/apt/manual_packages.list" apt install -y
        echo "→ Đã cài xong các gói"
    else
        echo "→ Bỏ qua bước cài gói"
    fi
else
    echo "→ Không tìm thấy danh sách gói"
fi

echo
echo "=== Khôi phục hoàn tất! ==="
echo "Khuyến nghị: Đăng xuất rồi đăng nhập lại để áp dụng hết cấu hình GNOME."
