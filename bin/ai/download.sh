#!/usr/bin/env bash
# Logic tải model (chọn tag, pull)

# Hiển thị danh sách model trong nhóm và chọn
select_model_from_list() {
    local -n models_ref=$1
    mapfile -t installed_base < <(get_installed_base_models)
    local display_menu=()

    for item in "${models_ref[@]}"; do
        local is_inst=0
        for inst in "${installed_base[@]}"; do
            if [ "$item" = "$inst" ]; then
                is_inst=1
                break
            fi
        done
        if [ $is_inst -eq 1 ]; then
            display_menu+=("$item  [ĐÃ CÀI]")
        else
            display_menu+=("$item")
        fi
    done

    echo -e "\n--- DANH SÁCH MODEL (${#display_menu[@]} models) ---"
    for i in "${!display_menu[@]}"; do
        printf " [%2d] %s\n" "$((i+1))" "${display_menu[i]}"
    done
    echo " [ 0] Quay lại nhóm chức năng"
    echo "----------------------------------------------------------"

    read -p "Chọn số model để xem tag [0-${#display_menu[@]}]: " mod_choice

    if [ "$mod_choice" = "0" ] || [ -z "$mod_choice" ]; then
        echo ""
        return 1
    elif [[ "$mod_choice" =~ ^[0-9]+$ ]] && [ "$mod_choice" -ge 1 ] && [ "$mod_choice" -le "${#display_menu[@]}" ]; then
        echo "${models_ref[$((mod_choice-1))]}" | awk '{print $1}'
        return 0
    else
        echo "Lựa chọn không hợp lệ."
        return 1
    fi
}

# Chọn tag và tải model
select_and_pull_tag() {
    local target_base="$1"

    while true; do
        echo -e "\n>>> Đang lấy các phiên bản của '$target_base'..."
        mapfile -t all_raw_tags < <(fetch_model_tags "$target_base")

        if [ ${#all_raw_tags[@]} -eq 0 ]; then
            echo "Không tự động lấy được danh sách tag. Đang tải bản mặc định 'latest'..."
            ollama pull "$target_base"
            break
        fi

        local popular_tags=()
        local other_tags=()

        for entry in "${all_raw_tags[@]}"; do
            local t_name
            t_name=$(echo "$entry" | cut -d'|' -f1)
            if [[ "$t_name" =~ ^(latest|[0-9]+(\.[0-9]+)?b(-instruct)?)$ ]] || [[ "$t_name" =~ ^(cloud|[0-9]+b)$ ]]; then
                popular_tags+=("$entry")
            else
                other_tags+=("$entry")
            fi
        done

        local selected_tags_pool
        if [ ${#popular_tags[@]} -eq 0 ]; then
            selected_tags_pool=("${all_raw_tags[@]}")
        else
            selected_tags_pool=("${popular_tags[@]}")
        fi

        mapfile -t local_installed < <(get_installed_models)

        local table_entries=()
        local buffer_table="STT|TÊN PHIÊN BẢN (TAG)|DUNG LƯỢNG|TRẠNG THÁI\n"
        local idx=1

        for item in "${selected_tags_pool[@]}"; do
            local t_name t_size full_name status
            t_name=$(echo "$item" | cut -d'|' -f1 | tr -d '\r\n ')
            t_size=$(echo "$item" | cut -d'|' -f2 | tr -d '\r\n ')
            full_name="${target_base}:${t_name}"

            status="LOCAL [OFFLINE]"
            [[ "$t_name" =~ cloud ]] && status="CLOUD [ONLINE]"
            for loc in "${local_installed[@]}"; do
                if [ "$loc" = "$full_name" ]; then
                    status="ĐÃ CÓ TRÊN MÁY"
                    break
                fi
            done

            buffer_table+="$(printf "[%2d]" "$idx")|${t_name}|${t_size}|${status}\n"
            table_entries+=("$t_name|$status")
            ((idx++))
        done

        local opt_full=$idx
        local opt_custom=$((idx + 1))

        if [ ${#other_tags[@]} -gt 0 ]; then
            buffer_table+="$(printf "[%2d]" "$opt_full")|--> Xem tất cả bản lượng tử hóa khác (${#other_tags[@]} bản)||\n"
        fi
        buffer_table+="$(printf "[%2d]" "$opt_custom")|--> Tự gõ tay tag khác||\n"
        buffer_table+="[ 0]|--> Quay lại danh sách model||\n"

        print_auto_table "CÁC PHIÊN BẢN CỦA: $target_base" "$buffer_table"

        read -p "Chọn số thứ tự phiên bản để tải [0-$opt_custom]: " tag_choice

        if [ "$tag_choice" = "0" ] || [ -z "$tag_choice" ]; then
            break
        elif [ "$tag_choice" = "$opt_full" ] && [ ${#other_tags[@]} -gt 0 ]; then
            _show_all_tags_and_pull "$target_base" "${all_raw_tags[@]}"
            break
        elif [ "$tag_choice" = "$opt_custom" ]; then
            read -p "Nhập tag tùy chọn (bấm 0 để quay lại): " custom_t
            if [ "$custom_t" != "0" ] && [ -n "$custom_t" ]; then
                ollama pull "${target_base}:${custom_t}"
                read -p $'\nNhấn Enter để tiếp tục...'
                break
            fi
        elif [[ "$tag_choice" =~ ^[0-9]+$ ]] && [ "$tag_choice" -ge 1 ] && [ "$tag_choice" -le "${#table_entries[@]}" ]; then
            _pull_selected_tag "$target_base" "${table_entries[$((tag_choice - 1))]}"
            break
        else
            echo "Lựa chọn không hợp lệ."
        fi
    done
}

# Hiển thị toàn bộ tag và tải
_show_all_tags_and_pull() {
    local target_base="$1"
    shift
    local all_raw_tags=("$@")
    mapfile -t local_installed < <(get_installed_models)

    local full_buffer="STT|TÊN PHIÊN BẢN (TAG)|DUNG LƯỢNG|TRẠNG THÁI\n"
    local all_entries=()
    local f_idx=1

    for ot in "${all_raw_tags[@]}"; do
        local ot_name ot_size ot_fullname ot_status
        ot_name=$(echo "$ot" | cut -d'|' -f1 | tr -d '\r\n ')
        ot_size=$(echo "$ot" | cut -d'|' -f2 | tr -d '\r\n ')
        ot_fullname="${target_base}:${ot_name}"

        ot_status="LOCAL [OFFLINE]"
        [[ "$ot_name" =~ cloud ]] && ot_status="CLOUD [ONLINE]"
        for loc in "${local_installed[@]}"; do
            if [ "$loc" = "$ot_fullname" ]; then
                ot_status="ĐÃ CÓ TRÊN MÁY"
                break
            fi
        done

        full_buffer+="$(printf "[%3d]" "$f_idx")|${ot_name}|${ot_size}|${ot_status}\n"
        all_entries+=("$ot_name|$ot_status")
        ((f_idx++))
    done
    full_buffer+="[  0]|--> Quay lại bảng thu gọn||\n"

    print_auto_table "TOÀN BỘ CÁC BẢN CỦA: $target_base (${#all_entries[@]} bản)" "$full_buffer"

    read -p "Nhập số thứ tự phiên bản cần tải [0-${#all_entries[@]}]: " full_choice
    if [ "$full_choice" = "0" ] || [ -z "$full_choice" ]; then
        return
    elif [[ "$full_choice" =~ ^[0-9]+$ ]] && [ "$full_choice" -ge 1 ] && [ "$full_choice" -le "${#all_entries[@]}" ]; then
        local sel_ot="${all_entries[$((full_choice - 1))]}"
        local target_tag
        target_tag=$(echo "$sel_ot" | cut -d'|' -f1)
        echo -e "\n>>> Bắt đầu tải: ${target_base}:${target_tag} ..."
        ollama pull "${target_base}:${target_tag}"
        read -p $'\nNhấn Enter để tiếp tục...'
    else
        echo "Lựa chọn không hợp lệ."
    fi
}

# Xác nhận và pull tag đã chọn
_pull_selected_tag() {
    local target_base="$1"
    local sel_entry="$2"
    local target_tag target_stat full_pull

    target_tag=$(echo "$sel_entry" | cut -d'|' -f1)
    target_stat=$(echo "$sel_entry" | cut -d'|' -f2)
    full_pull="${target_base}:${target_tag}"

    if [[ "$target_stat" =~ "ĐÃ CÓ TRÊN MÁY" ]]; then
        read -p "Model này đã có trên máy. Bạn có muốn tải lại (ghi đè)? (y/N): " re_dl
        if [[ ! "$re_dl" =~ ^[Yy]$ ]]; then
            echo "Đã hủy."
            return
        fi
    elif [[ "$target_stat" =~ "CLOUD" ]]; then
        echo -e "\n[CẢNH BÁO]: Đây là bản Cloud API Wrapper, không chạy thuần Offline!"
        read -p "Bạn vẫn muốn tiếp tục tải? (y/N): " confirm_cloud
        if [[ ! "$confirm_cloud" =~ ^[Yy]$ ]]; then
            echo "Đã hủy."
            return
        fi
    fi

    echo -e "\n>>> Bắt đầu tải: $full_pull ..."
    ollama pull "$full_pull"
    read -p $'\nNhấn Enter để tiếp tục...'
}
