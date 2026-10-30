#!/usr/bin/env bash
# Hàm in bảng tự co giãn

print_auto_table() {
    local title="$1"
    local raw_buffer="$2"

    # Định dạng bằng column trước
    local formatted_table
    formatted_table=$(echo -e "$raw_buffer" | column -t -s '|' -o ' | ')

    # Đo chiều dài lớn nhất của bảng
    local max_len
    max_len=$(echo "$formatted_table" | awk '{ if (length > max) max = length } END { print max }')
    [ -z "$max_len" ] || [ "$max_len" -lt 40 ] && max_len=75

    # Tạo đường kẻ bằng đúng max_len
    local border_line
    border_line=$(printf "%${max_len}s" "" | tr ' ' '=')
    local dash_line
    dash_line=$(printf "%${max_len}s" "" | tr ' ' '-')

    # In tiêu đề căn giữa
    echo -e "\n$border_line"
    local pad=$(( (max_len - ${#title}) / 2 ))
    [ $pad -lt 0 ] && pad=0
    printf "%${pad}s%s\n" "" "$title"
    echo "$border_line"

    # In dòng header
    echo "$formatted_table" | head -n 1
    echo "$dash_line"

    # In nội dung bên dưới
    echo "$formatted_table" | tail -n +2
    echo "$border_line"
}
