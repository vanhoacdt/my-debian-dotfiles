#!/usr/bin/env bash
# Entry point - Trình quản lý AI (Ollama)
# Tách module để dễ bảo trì

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_DIR="$SCRIPT_DIR/ai"

# Load các module
source "$AI_DIR/models.sh"
source "$AI_DIR/fetch.sh"
source "$AI_DIR/table.sh"
source "$AI_DIR/categories.sh"
source "$AI_DIR/download.sh"
source "$AI_DIR/explore.sh"
source "$AI_DIR/menu.sh"

# Chạy menu chính
run_main_loop
