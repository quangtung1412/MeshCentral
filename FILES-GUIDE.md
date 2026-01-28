# Files trong project

## ✅ COMMIT lên Git (Safe to share)

```
docker-compose.yaml              # Docker config (không có passwords)
config.json                      # Template với placeholders
.env.example                     # Template env vars (không có passwords thật)
.gitignore                       # Ignore các file sensitive
generate-config.ps1              # Script để generate config
QUICK-START.md                   # Hướng dẫn nhanh
ENV-SETUP.md                     # Hướng dẫn chi tiết về .env
DEPLOYMENT.md                    # Hướng dẫn deploy
SETUP-GUIDE.md                   # Hướng dẫn setup
cloudflare-tunnel-setup.md       # Setup Cloudflare
agent-reconnect-guide.md         # Troubleshoot agents
```

## ❌ KHÔNG commit (Có trong .gitignore)

```
.env                            # Chứa passwords thật
config.runtime.json             # Config đã điền passwords
backup/                          # Backup data
*.tar.gz                         # Archive files
config.json.backup              # Config backups
```

## 🗂️ Files không cần thiết (có thể xóa)

```
fix-config.sh                    # Script test (không dùng)
config.json.old                  # Backups cũ (nếu có)
```

## 📝 Workflow sử dụng

### Developer (local)
1. Copy `.env.example` → `.env`
2. Điền passwords vào `.env`
3. Run `.\generate-config.ps1`
4. Run `docker compose up -d`

### Git commit
```powershell
# Các files này AN TOÀN để commit
git add docker-compose.yaml
git add config.json
git add .env.example
git add .gitignore
git add generate-config.ps1
git add *.md

# KHÔNG BAO GIỜ commit
# .env (đã auto-ignore)
# config.runtime.json (đã auto-ignore)
```

### Deploy máy mới
```powershell
# 1. Clone repo
git clone <repo>

# 2. Setup
Copy-Item .env.example .env
# Edit .env với passwords

# 3. Generate & Run
.\generate-config.ps1
docker compose up -d
```

## 🔐 Bảo mật

### Passwords được lưu ở đâu?
- **File .env** (local, không commit)
- Password manager (1Password, Bitwarden...)
- Secrets manager (AWS Secrets, Vault...)

### Shared secret với team?
- Share `.env.example` (không có passwords)
- Mỗi người tự tạo `.env` riêng
- Hoặc dùng secrets manager để sync

### Backup .env
```powershell
# Encrypt backup
gpg -c .env
# Tạo file .env.gpg (encrypted)

# Restore
gpg .env.gpg
```

## 📊 File structure tổng quan

```
MeshCentral/
├── 📄 docker-compose.yaml       ← Commit (safe)
├── 📄 config.json                ← Commit (template)
├── 🔒 .env                       ← KHÔNG commit (secrets)
├── 📄 .env.example               ← Commit (template)
├── 🔒 config.runtime.json        ← KHÔNG commit (auto-gen)
├── 📄 generate-config.ps1        ← Commit (script)
├── 📄 .gitignore                 ← Commit (important!)
├── 📚 QUICK-START.md             ← Commit (docs)
├── 📚 ENV-SETUP.md               ← Commit (docs)
├── 📚 DEPLOYMENT.md              ← Commit (docs)
└── ... other docs ...
```

## 🎯 Quick commands

```powershell
# Generate config từ .env
.\generate-config.ps1

# Start services
docker compose up -d

# View logs
docker compose logs -f meshcentral

# Restart
docker compose restart meshcentral

# Stop và XÓA data
docker compose down -v

# Check .env không bị track
git status | Select-String ".env"
# → Không có kết quả = Good!
```
