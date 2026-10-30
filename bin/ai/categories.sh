#!/usr/bin/env bash
# Định nghĩa danh mục model theo nhóm

get_category_models() {
    local group="$1"
    case $group in
        1)  # Lập trình & Viết Code
            echo "qwen2.5-coder codestral deepseek-coder deepseek-coder-v2 codellama starcoder2 yi-coder sqlcoder duckdb-nsql magicoder"
            ;;
        2)  # Đa năng, Trò chuyện
            echo "llama3.2 llama3.1 qwen2.5 mistral mistral-nemo gemma2 phi4 phi4-mini smollm2 hermes3 dolphin3 vicuna"
            ;;
        3)  # Suy luận logic sâu & Toán học
            echo "deepseek-r1 qwq phi4-reasoning qwen2-math mathstral marco-o1 deepscaler openthinker"
            ;;
        4)  # Thị giác & OCR
            echo "llava llama3.2-vision qwen2.5vl bakllava moondream minicpm-v deepseek-ocr glm-ocr"
            ;;
        5)  # Embedding / RAG
            echo "bge-m3 bge-large nomic-embed-text all-minilm mxbai-embed-large snowflake-arctic-embed"
            ;;
        6)  # Y tế & Trích xuất
            echo "medgemma meditron medllama2 nuextract reader-lm translategemma"
            ;;
        *)
            echo ""
            ;;
    esac
}

show_category_menu() {
    echo -e "\n=========================================================="
    echo "              KHÁM PHÁ & TẢI MODEL THEO NHÓM              "
    echo "=========================================================="
    echo " 1. Lập trình & Viết Code (Coding & Dev)"
    echo " 2. Đa năng, Trò chuyện & Tri thức (General Chat)"
    echo " 3. Suy luận logic sâu & Toán học (Deep Reasoning/Math)"
    echo " 4. Thị giác & Nhận dạng ảnh / OCR (Vision & OCR)"
    echo " 5. Tìm kiếm ngữ nghĩa / RAG (Embedding Vector)"
    echo " 6. Chuyên ngành Y tế & Trích xuất (Medical & Data)"
    echo " 7. Tìm kiếm model theo từ khóa tùy chọn"
    echo " 8. Toàn bộ danh mục Ollama Library"
    echo " 9. Nhập trực tiếp tên model/tag để tải ngay"
    echo " 0. Quay lại Menu chính"
    echo "=========================================================="
}
