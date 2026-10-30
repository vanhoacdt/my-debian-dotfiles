#!/bin/bash
STATE_FILE="/tmp/gnome_workspace_history"

# Lấy workspace hiện tại (chỉ số từ 0)
CURRENT=$(wmctrl -d | awk '/\*/ {print $1}')

if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
    LAST=0
else
    LAST=$(cat "$STATE_FILE")
fi

# Nếu workspace hiện tại khác workspace cũ đã lưu, nhảy về workspace cũ
if [ "$CURRENT" -ne "$LAST" ]; then
    echo "$CURRENT" > "$STATE_FILE"
    wmctrl -s "$LAST"
else
    # Nếu chưa có lịch sử khác (đang đứng đúng vị trí cũ), nhảy tạm sang workspace 0 hoặc 1
    TARGET=$(( CURRENT == 0 ? 1 : 0 ))
    echo "$CURRENT" > "$STATE_FILE"
    wmctrl -s "$TARGET"
fi
