#!/usr/bin/env bash
# Lấy thông tin model từ ollama.com

# Lấy danh mục model từ ollama.com
fetch_ollama_library() {
    local query="$1"
    local url="https://ollama.com/library"
    if [ -n "$query" ]; then
        url="https://ollama.com/search?q=${query}"
    fi
    curl -sL "$url" | grep -o 'href="/library/[^"]*"' | sed 's#href="/library/##; s#"##g' | grep -v '/' | sort -u
}

# Bóc tách danh sách tag và dung lượng của model từ Ollama
fetch_model_tags() {
    local model="$1"
    local html
    html=$(curl -sL "https://ollama.com/library/${model}/tags")

    local tags
    tags=$(echo "$html" | grep -o "href=\"/library/${model}:[^\"]*\"" | sed "s#href=\"/library/${model}:##; s#\"##g" | grep -v '/' | sort -u)

    if [ -z "$tags" ]; then
        return
    fi

    while IFS= read -r t; do
        [ -z "$t" ] && continue
        local sz
        sz=$(echo "$html" | grep -A 25 "href=\"/library/${model}:${t}\"" | grep -oE '[0-9]+(\.[0-9]+)?[[:space:]]*(GB|MB)' | head -n 1 | tr -d '\r\n ')
        if [ -n "$sz" ]; then
            echo "${t}|${sz}"
        else
            echo "${t}|N/A"
        fi
    done <<< "$tags"
}
