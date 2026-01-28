# ✅ Setup Hoàn Tất - Hướng Dẫn Sử Dụng

## 📦 Files quan trọng (commit lên Git)

1. **docker-compose.yaml** - Docker config  
2. **config.json** - Template config (có placeholders)
3. **.env.example** - Template env vars (KHÔNG có passwords thật)
4. **generate-config.ps1** - Script generate config từ .env
5. **.gitignore** - Đã config ignore .env

## 🔐 Files bảo mật (KHÔNG commit)

1. **.env** - Chứa passwords thật
2. **config.runtime.json** - Config đã điền passwords (auto-generated)

## 🚀 Workflow Deploy

### Lần đầu (máy mới)

**Trên Windows (PowerShell):**
```powershell
# 1. Clone repo
git clone <your-repo>
cd MeshCentral

# 2. Tạo .env từ template  
Copy-Item .env.example .env

# 3. Sửa .env - ĐỔI CÁC GIÁ TRỊ SAU:
# - HOSTNAME=your-domain.com
# - MYSQL_ROOT_PASSWORD=your_secure_password
# - MYSQL_PASSWORD=your_secure_password  

# 4. Generate config
.\generate-config.ps1

# 5. Khởi động
docker compose up -d

# 6. Kiểm tra logs
docker compose logs -f meshcentral
```

**Trên Linux/Ubuntu (Bash):**
```bash
# 1. Clone repo
git clone <your-repo>
cd MeshCentral

# 2. Tạo .env từ template  
cp .env.example .env

# 3. Sửa .env - ĐỔI CÁC GIÁ TRỊ SAU:
nano .env
# hoặc vim .env

# 4. Generate config
chmod +x generate-config.sh
./generate-config.sh

# 5. Khởi động
docker compose up -d

# 6. Kiểm tra logs
docker compose logs -f meshcentral
```

### Cập nhật config

**Windows:**
```powershell
# 1. Sửa file .env
notepad .env

# 2. Generate lại config
.\generate-config.ps1

# 3. Restart
docker compose restart meshcentral
```

**Linux/Ubuntu:**
**Windows:**
```powershell
# 1. Sửa .env
notepad .env
# Thay đổi: HOSTNAME=new-domain.com hoặc MYSQL_PASSWORD=new_password

# 2. Generate config mới
.\generate-config.ps1

# 3. Nếu đổi DB password, phải recreate tất cả
docker compose down -v
docker compose up -d

# 4. Nếu chỉ đổi domain, restart là đủ
docker compose restart meshcentral
```

**Linux/Ubuntu:**
```bash
# 1. Sửa .env
nano .env
# Thay đổi: HOSTNAME=new-domain.com hoặc MYSQL_PASSWORD=new_password

# 2. Generate config mới
./generate-config.sh
# 3. Restart
docker compose restart meshcentral
```

### Thay đổi domain hoặc password

```powershell
# 1. Sửa .env
HOSTNAME=new-domain.com
MYSQL_PASSWORD=new_password

# 2. Generate config mới
.\generate-config.ps1

# 3. Nếu đổi DB password, phải recreate tất cả
docker compose down -v
docker compose up -d

# 4. Nếu chỉ đổi domain, restart là đủ
docker compose restart meshcentral
```

## ✨ Các file được generate tự động

- **config.runtime.json** - Được tạo khi chạy `generate-config.ps1`
- File này được mount vào container để MeshCentral sử dụng
- **KHÔNG commit** file này lên Git (đã có trong .gitignore)

## 🔍 Kiểm tra setup

```powershell
# Config đã generate đúng chưa?
Get-Content config.runtime.json

# Container đang chạy?
docker compose ps

# Logs có lỗi không?
docker compose logs meshcentral | Select-String -Pattern "error|ERROR"

# Server đã khởi động?
docker compose logs meshcentral | Select-String -Pattern "running on port"
```

## 📋 Checklist bảo mật

- [ ] File `.env` đã được tạo và điền đầy đủ
- [ ] `MYSQL_ROOT_PASSWORD` đã đổi (không dùng default)
- [ ] `MYSQL_PASSWORD` đã đổi (không dùng default)
- [ ] File `.env` **KHÔNG** có trong `git status`
- [ ] File `config.runtime.json` **KHÔNG** có trong `git status`
**Windows:**
```powershell
.\generate-config.ps1
```

**Linux/Ubuntu:**
```bash
./generate-config.sh

### "Access denied for user"
```powershell
# Kiểm tra password trong .env
Get-Content .env | Select-String "MYSQL_PASSWORD"

# Regenerate config
.\generate-config.ps1

# Recreate containers
docker compose down -v
docker compose up -d
```

### "config.runtime.json not found"
```powershell
# Phải chạy generate script trước
.\generate-config.ps1
```

### "TLSOffload không hoạt động"
```powershell
# Xem config runtime
Get-Content config.runtime.json | Select-String "TLSOffload"

# Phải là true cho Cloudflare Tunnel
```

### Container không khởi động
```powershell
# Xem full logs
docker compose logs meshcentral

# Kiểm tra MySQL
docker compose logs mysql
```

## 📝 Cấu trúc .env

```env
# Domain
HOSTNAME=your-domain.com

# Database (BẮT BUỘC ĐỔI!)
MYSQL_ROOT_PASSWORD=secure_password_here
MYSQL_PASSWORD=secure_password_here

# Features
ALLOW_NEW_ACCOUNTS=true    # Set false sau khi tạo accounts
WEBRTC=true                 # Remote desktop tốt hơn
TLS_OFFLOAD=true           # true nếu dùng Cloudflare
```

## 🎯 Best Practices

1. **Luôn backup .env file** - Lưu vào password manager
2. **Không share .env** - Mỗi env riêng file .env riêng
3. **Regenerate sau khi sửa** - Chạy `.\generate-config.ps1` mỗi lần sửa .env
4. **Test sau mỗi thay đổi** - Kiểm tra logs sau khi restart
5. **Version control** - Chỉ commit .env.example, không commit .env

## 🚢 Deploy Production

```powershell
# 1. Đổi tất cả passwords trong .env
# 2. Set ALLOW_NEW_ACCOUNTS=false sau khi tạo accounts
# 3. Backup .env vào nơi an toàn
# 4. Setup Cloudflare Tunnel (xem cloudflare-tunnel-setup.md)
# 5. Test kỹ càng trước khi đưa vào sử dụng
```

## 📚 Tài liệu khác

- [ENV-SETUP.md](ENV-SETUP.md) - Chi tiết về .env setup
- [cloudflare-tunnel-setup.md](cloudflare-tunnel-setup.md) - Setup Cloudflare Tunnel
- [agent-reconnect-guide.md](agent-reconnect-guide.md) - Fix agent không connect
