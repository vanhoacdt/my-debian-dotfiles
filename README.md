# Debian GNOME Dotfiles

Bộ công cụ tự động **sao lưu** và **khôi phục** toàn diện môi trường làm việc trên **Debian + GNOME**.

Hỗ trợ backup/restore:
- Cấu hình GNOME (phím tắt, giao diện, extensions settings…) qua `dconf`
- Scripts cá nhân trong `~/.local/bin`
- Dotfiles (`.bashrc`, `.profile`, `.gitconfig`)
- Danh sách gói APT đã cài thủ công

---

## Tính năng nổi bật

- **Alt + Tab** chuyển từng cửa sổ riêng biệt (không gom nhóm theo ứng dụng)
- **Win + Tab** chuyển qua lại giữa 2 Workspace gần nhất (Most Recently Used)
- **Ctrl + Alt + T** mở GNOME Terminal
- Script quản lý Ollama AI (`ai-selector.sh`) tiện lợi
- Backup & Restore chỉ với **1 lệnh**

---

## Cấu trúc thư mục

```
my-debian-dotfiles/
├── apt/
│   └── manual_packages.list          # Danh sách gói APT
├── bin/
│   ├── ai-selector.sh                # Entry point quản lý Ollama
│   ├── ai/                           # Module AI (tách nhỏ)
│   │   ├── models.sh                 # Chạy / xem / xóa model
│   │   ├── fetch.sh                  # Lấy data từ ollama.com
│   │   ├── table.sh                  # In bảng đẹp
│   │   ├── categories.sh             # Danh mục model theo nhóm
│   │   ├── download.sh               # Logic chọn tag & pull
│   │   ├── explore.sh                # Menu khám phá & tải
│   │   └── menu.sh                   # Menu chính
│   ├── backup-to-github.sh           # Script sao lưu
│   └── toggle-workspace.sh           # Chuyển workspace MRU
├── configs/
│   ├── .bashrc
│   ├── .profile
│   └── .gitconfig
├── dconf/
│   ├── full_gnome.dconf              # Dump đầy đủ (backup)
│   └── parts/                        # Tách nhỏ theo nhóm
│       ├── 00-misc.dconf
│       ├── 01-desktop.dconf          # Giao diện, touchpad...
│       ├── 02-keybindings.dconf      # Alt+Tab, Win+Tab, Ctrl+Alt+T
│       ├── 03-shell-extensions.dconf # Extensions (dash-to-dock...)
│       ├── 04-evolution.dconf
│       └── 05-apps.dconf             # Nautilus, Terminal...
├── restore.sh                        # Script khôi phục
└── README.md
```

---

## Yêu cầu

- Debian 12 (Bookworm) trở lên
- GNOME Desktop
- Đã cài `git`, `dconf-cli`, `wmctrl`

---

## 1. Khôi phục (Restore) trên máy mới

Chỉ cần chạy **một lệnh**:

```bash
git clone https://github.com/hoavn1437/my-debian-dotfiles.git ~/my-debian-dotfiles \
  && cd ~/my-debian-dotfiles \
  && chmod +x restore.sh \
  && ./restore.sh
```

Script sẽ tự động:
1. Cài `wmctrl` và các công cụ cần thiết
2. Load toàn bộ cấu hình GNOME (`dconf`)
3. Copy scripts vào `~/.local/bin` và cấp quyền thực thi
4. Khôi phục `.bashrc`, `.profile`, `.gitconfig`
5. Hỏi xác nhận trước khi cài lại các gói APT

> **Khuyến nghị**: Sau khi restore xong, **đăng xuất rồi đăng nhập lại** để áp dụng hết cấu hình.

---

## 2. Sao lưu (Backup) trên máy đang dùng

Mỗi khi bạn thay đổi phím tắt, cài thêm phần mềm, hoặc viết script mới, chỉ cần chạy:

```bash
~/my-debian-dotfiles/bin/backup-to-github.sh
```

Hoặc nếu đang ở trong thư mục repo:

```bash
./bin/backup-to-github.sh
```

Script sẽ tự động:
- Dump cấu hình GNOME
- Lưu danh sách gói APT (đã lọc)
- Sao lưu toàn bộ `~/.local/bin`
- Sao lưu dotfiles
- Commit + Push lên GitHub với timestamp

---

## 3. Cấu hình Git (lần đầu trên máy mới)

Sau khi restore, nếu muốn máy mới cũng có thể backup lên GitHub:

```bash
git config --global user.name "Nguyen Van Hoa"
git config --global user.email "hoavn1437@gmail.com"
git config --global credential.helper "cache --timeout=28800"
```

Lần đầu chạy backup, Git sẽ hỏi:
- **Username**: `hoavn1437`
- **Password**: Personal Access Token (PAT) của GitHub

> Token chỉ được lưu tạm trong 8 tiếng (an toàn hơn `store`).

---

## Bảo mật

- Không sử dụng `credential.helper = store` (tránh lưu token vĩnh viễn dạng plain text)
- Có file `.gitignore` để tránh commit nhầm token / credentials
- Script restore **hỏi xác nhận** trước khi cài hàng loạt gói APT
- Không hardcode đường dẫn tuyệt đối

---

## Ghi chú

- Script `toggle-workspace.sh` cần `wmctrl` (đã được cài tự động khi restore).
- `ai-selector.sh` yêu cầu đã cài [Ollama](https://ollama.com).
- Danh sách gói APT được lọc bớt các gói hệ thống cơ bản để tránh conflict khi restore.

---

## License

MIT License – Bạn có thể tự do sử dụng và chỉnh sửa theo nhu cầu cá nhân.
