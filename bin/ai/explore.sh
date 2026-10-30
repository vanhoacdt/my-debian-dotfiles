#!/usr/bin/env bash
# Menu khám phá & tải model theo nhóm

explore_and_download() {
    while true; do
        show_category_menu
        read -p "Chọn nhóm chức năng [0-9]: " group_choice

        [ "$group_choice" = "0" ] && break

        local category_models=()

        case $group_choice in
            1|2|3|4|5|6)
                read -ra category_models <<< "$(get_category_models "$group_choice")"
                ;;
            7)
                read -p "Nhập từ khóa tìm kiếm (bấm 0 để quay lại): " search_kw
                [ "$search_kw" = "0" ] && continue
                if [ -n "$search_kw" ]; then
                    echo -e "\n>>> Đang tìm kiếm '$search_kw' trên Ollama..."
                    mapfile -t category_models < <(fetch_ollama_library "$search_kw")
                fi
                ;;
            8)
                echo -e "\n>>> Đang tải toàn bộ danh mục từ Ollama Library..."
                mapfile -t category_models < <(fetch_ollama_library)
                ;;
            9)
                read -p "Nhập tên model đầy đủ (ví dụ: llama3.2:3b, bấm 0 để hủy): " direct_model
                if [ "$direct_model" = "0" ] || [ -z "$direct_model" ]; then
                    continue
                fi
                echo -e "\n>>> Đang tải: $direct_model ..."
                ollama pull "$direct_model"
                read -p $'\nNhấn Enter để tiếp tục...'
                continue
                ;;
            *)
                echo "Lựa chọn không hợp lệ."
                continue
                ;;
        esac

        if [ ${#category_models[@]} -eq 0 ]; then
            echo "Không tìm thấy model nào."
            continue
        fi

        while true; do
            local target_base
            target_base=$(select_model_from_list category_models)
            if [ -z "$target_base" ]; then
                break
            fi
            select_and_pull_tag "$target_base"
        done
    done
}
