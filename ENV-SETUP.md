# 🔐 Setup với .env (Bảo mật)

## Cấu trúc files

```
MeshCentral/
├── docker-compose.yaml       # Docker config (KHÔNG chứa secrets)
├── .env                       # Secrets (KHÔNG commit lên Git)
├── .env.example               # Template (Commit lên Git)
├── .gitignore                 # Ignore .env file
└── docs/
```

## Setup nhanh

### 1. Clone repo

```bash
git clone <your-repo>
cd MeshCentral
```

### 2. Tạo file .env từ template

```bash
# Windows PowerShell
Copy-Item .env.example .env

# Linux/Mac
cp .env.example .env
```

### 3. Chỉnh sửa file .env

Mở file `.env` và **BẮT BUỘC** thay đổi:

```env
# Domain của bạn
HOSTNAME=your-domain.com
REVERSE_PROXY=your-domain.com

# Database passwords (ĐỔI NGAY!)
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_PASSWORD=your_secure_password
MARIADB_PASS=your_secure_password  # Phải giống MYSQL_PASSWORD
```

### 4. Khởi động

```bash
docker compose up -d
```

## ⚠️ Quan trọng

### File .env KHÔNG được commit lên Git!

File `.gitignore` đã được cấu hình để ignore `.env`. Kiểm tra:

```bash
git status
# .env KHÔNG được hiển thị trong danh sách
```

### Chia sẻ với team

- ✅ **Commit**: `.env.example` (template không có passwords)
- ❌ **KHÔNG commit**: `.env` (chứa passwords thực)

## Migrate từ config.json cũ

Nếu bạn đang dùng `config.json` cũ:

1. **Backup** config cũ:
```bash
cp config.json config.json.backup
```

2. **Xóa mount** config.json trong docker-compose.yaml (đã làm rồi)

3. **Di chuyển secrets** sang `.env`

4. **Restart**:
```bash
docker compose down
docker compose up -d
```

## Biến môi trường quan trọng

### Domain & Network
```env
HOSTNAME=your-domain.com              # Domain chính
REVERSE_PROXY=your-domain.com         # Reverse proxy domain
REVERSE_PROXY_TLS_PORT=443            # TLS port
```

### Database (BẮT BUỘC ĐỔI)
```env
MYSQL_ROOT_PASSWORD=xxx               # MySQL root password
MYSQL_PASSWORD=xxx                    # MySQL user password
MARIADB_PASS=xxx                      # Phải giống MYSQL_PASSWORD
```

### Features
```env
WEBRTC=true                           # Bật WebRTC
ALLOW_NEW_ACCOUNTS=true               # Cho phép đăng ký
ALLOWED_ORIGIN=true                   # Cho phép CORS
TLS_OFFLOAD=true                      # Cho Cloudflare Tunnel
```

## Production Checklist

Trước khi deploy:

- [ ] Copy `.env.example` thành `.env`
- [ ] Đổi `HOSTNAME` thành domain thật
- [ ] Đổi `MYSQL_ROOT_PASSWORD` (mật khẩu mạnh)
- [ ] Đổi `MYSQL_PASSWORD` và `MARIADB_PASS` (phải giống nhau)
- [ ] Kiểm tra `.env` KHÔNG có trong git: `git status`
- [ ] Set `ALLOW_NEW_ACCOUNTS=false` sau khi tạo accounts
- [ ] Backup file `.env` ở nơi an toàn (password manager, vault...)

## Troubleshooting

### "Access denied for user"
→ `MYSQL_PASSWORD` và `MARIADB_PASS` không khớp nhau trong `.env`

### "Cannot connect to database"
→ Kiểm tra `MARIADB_HOST=mysql` (phải là service name)

### Variables không được load
→ Kiểm tra format trong `.env`:
```env
# Đúng
HOSTNAME=example.com

# SAI
HOSTNAME = example.com    # không có spaces
HOSTNAME="example.com"    # không cần quotes
```

## Backup .env file

File `.env` rất quan trọng! Backup an toàn:

```bash
# Option 1: Encrypted backup
gpg -c .env           # Tạo .env.gpg (encrypted)

# Option 2: Password manager
# Copy nội dung .env vào 1Password, Bitwarden, etc.

# Option 3: Secure vault
# Upload vào HashiCorp Vault, AWS Secrets Manager, etc.
```

## Deploy sang máy mới

```bash
# 1. Clone repo
git clone <repo>
cd MeshCentral

# 2. Tạo .env mới HOẶC restore từ backup
cp .env.example .env
# Điền thông tin secrets

# 3. Deploy
docker compose up -d
```

## Xem logs

```bash
# Xem tất cả logs
docker compose logs -f

# Chỉ MeshCentral
docker compose logs -f meshcentral

# Kiểm tra config có load đúng không
docker compose logs meshcentral | grep -i "Setting"
```
