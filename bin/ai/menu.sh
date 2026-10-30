#!/usr/bin/env bash
# Menu chính của trình quản lý AI

show_main_menu() {
    clear
    echo "=========================================================="
    echo "                 TRÌNH QUẢN LÝ AI (OLLAMA)                "
    echo "=========================================================="
    echo " 1. Chạy / Chat với một Model (Offline)"
    echo " 2. Xem trạng thái nạp RAM / VRAM (ollama ps)"
    echo " 3. Xem cấu hình chi tiết của Model (ollama show)"
    echo " 4. Khám phá & Tải Model (Phân loại gọn gàng)"
    echo " 5. Xóa Model giải phóng ổ đĩa (ollama rm)"
    echo " 0. Thoát"
    echo "=========================================================="
}

run_main_loop() {
    while true; do
        show_main_menu
        read -p "Chọn chức năng [0-5]: " choice
        case $choice in
            1)
                run_model
                read -p $'\nNhấn Enter để về menu...'
                ;;
            2)
                show_status
                read -p $'\nNhấn Enter để về menu...'
                ;;
            3)
                show_model_info
                read -p $'\nNhấn Enter để về menu...'
                ;;
            4)
                explore_and_download
                ;;
            5)
                remove_model
                read -p $'\nNhấn Enter để về menu...'
                ;;
            0)
                echo "Tạm biệt!"
                exit 0
                ;;
            *)
                echo "Lựa chọn không hợp lệ!"
                sleep 1
                ;;
        esac
    done
}
