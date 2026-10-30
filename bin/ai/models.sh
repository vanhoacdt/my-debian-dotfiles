#!/usr/bin/env bash
# Quản lý model đã cài trên máy (offline)

# Lấy danh sách model offline (kèm tag, vd: llama3.2:3b)
get_installed_models() {
    ollama list | awk 'NR>1 {print $1}'
}

# Lấy danh sách model gốc offline (bỏ tag, vd: llama3.2)
get_installed_base_models() {
    ollama list | awk 'NR>1 {split($1, a, ":"); print a[1]}' | sort -u
}

# Chạy / chat với model
run_model() {
    mapfile -t models < <(get_installed_models)
    if [ ${#models[@]} -eq 0 ]; then
        echo "Chưa có model nào trên máy. Vui lòng tải trước từ mục 4!"
        return
    fi

    echo -e "\n=========================================================="
    echo "        DANH SÁCH MODEL KHẢ DỤNG ĐỂ CHẠY (OFFLINE)        "
    echo "=========================================================="
    for i in "${!models[@]}"; do
        printf " [%2d] %s\n" "$((i+1))" "${models[i]}"
    done
    echo " [ 0] Quay lại Menu chính"
    echo "=========================================================="

    read -p "Chọn model để chạy [0-${#models[@]}]: " run_idx
    if [ "$run_idx" = "0" ] || [ -z "$run_idx" ]; then
        return
    elif [[ "$run_idx" =~ ^[0-9]+$ ]] && [ "$run_idx" -ge 1 ] && [ "$run_idx" -le "${#models[@]}" ]; then
        target_run="${models[$((run_idx-1))]}"
        echo -e "\n>>> Đang khởi chạy: $target_run ...\n"
        ollama run "$target_run"
    else
        echo "Lựa chọn không hợp lệ."
    fi
}

# Xem trạng thái RAM/VRAM
show_status() {
    echo -e "\n=== MODEL ĐANG NẠP TRONG RAM / VRAM ==="
    ollama ps
    echo -e "\n=== TOÀN BỘ MODEL TRÊN Ổ CỨNG ==="
    ollama list
}

# Xem cấu hình chi tiết model
show_model_info() {
    mapfile -t models < <(get_installed_models)
    if [ ${#models[@]} -eq 0 ]; then
        echo "Không có model nào trên máy."
        return
    fi

    echo -e "\n--- XEM CHI TIẾT CẤU HÌNH (OFFLINE MODELS) ---"
    for i in "${!models[@]}"; do
        printf " [%2d] %s\n" "$((i+1))" "${models[i]}"
    done
    echo " [ 0] Quay lại Menu chính"
    echo "=========================================================="

    read -p "Chọn model muốn xem cấu hình [0-${#models[@]}]: " show_idx
    if [ "$show_idx" = "0" ] || [ -z "$show_idx" ]; then
        return
    elif [[ "$show_idx" =~ ^[0-9]+$ ]] && [ "$show_idx" -ge 1 ] && [ "$show_idx" -le "${#models[@]}" ]; then
        target_show="${models[$((show_idx-1))]}"
        echo -e "\n--- Thông tin cấu hình của $target_show ---"
        ollama show "$target_show"
    else
        echo "Lựa chọn không hợp lệ."
    fi
}

# Xóa model
remove_model() {
    mapfile -t models < <(get_installed_models)
    if [ ${#models[@]} -eq 0 ]; then
        echo "Không có model nào trên máy để xóa."
        return
    fi

    echo -e "\n=========================================================="
    echo "        XÓA MODEL KHỎI Ổ ĐĨA (CHỈ ÁP DỤNG OFFLINE)        "
    echo "=========================================================="
    for i in "${!models[@]}"; do
        printf " [%2d] %s\n" "$((i+1))" "${models[i]}"
    done
    echo " [ 0] Quay lại Menu chính"
    echo "=========================================================="

    read -p "Chọn model muốn xóa [0-${#models[@]}]: " rm_idx
    if [ "$rm_idx" = "0" ] || [ -z "$rm_idx" ]; then
        return
    elif [[ "$rm_idx" =~ ^[0-9]+$ ]] && [ "$rm_idx" -ge 1 ] && [ "$rm_idx" -le "${#models[@]}" ]; then
        m="${models[$((rm_idx-1))]}"
        read -p "Bạn có chắc chắn muốn xóa vĩnh viễn '$m'? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            ollama rm "$m"
            echo "Đã xóa $m."
        else
            echo "Đã hủy."
        fi
    else
        echo "Lựa chọn không hợp lệ."
    fi
}
