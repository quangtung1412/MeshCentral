# Files cần copy để "Chạy Phát Ăn Ngay" trên máy khác

## ✅ BẮT BUỘC (3 files)

1. **docker-compose.yaml** - Cấu hình Docker containers
2. **config.json** - Cấu hình MeshCentral (TLSOffload, domain, database...)
3. **cloudflare-tunnel-setup.md** - Hướng dẫn setup tunnel (nếu dùng Cloudflare)

## 📋 TÙY CHỌN (tài liệu tham khảo)

4. **SETUP-GUIDE.md** - Hướng dẫn setup chi tiết
5. **agent-reconnect-guide.md** - Hướng dẫn troubleshoot agent

## 🚀 Cách deploy trên máy mới

### Bước 1: Copy 3 files bắt buộc

```bash
# Tạo thư mục mới
mkdir MeshCentral
cd MeshCentral

# Copy 3 files vào:
# - docker-compose.yaml
# - config.json  
# - cloudflare-tunnel-setup.md (optional)
```

### Bước 2: Chỉnh sửa (nếu cần)

**Trong config.json:**
```json
{
  "settings": {
    "cert": "YOUR_DOMAIN_HERE",  // Đổi domain
    "mariaDB": {
      "password": "YOUR_DB_PASSWORD"  // Đổi password
    }
  },
  "domains": {
    "": {
      "certUrl": "YOUR_DOMAIN_HERE:443"  // Đổi domain
    }
  }
}
```

**Trong docker-compose.yaml:**
```yaml
environment:
  - MYSQL_ROOT_PASSWORD=YOUR_ROOT_PASSWORD  # Đổi password
  - MYSQL_PASSWORD=YOUR_DB_PASSWORD         # Phải khớp config.json
```

### Bước 3: Chạy

```bash
docker compose up -d
```

### Bước 4: Setup Cloudflare Tunnel (nếu cần remote access)

Xem file: cloudflare-tunnel-setup.md

### Bước 5: Truy cập và tạo admin

- Truy cập: https://YOUR_DOMAIN hoặc https://localhost
- Tạo tài khoản đầu tiên (sẽ là admin)

## ⚙️ Cấu hình đã được thiết lập sẵn

✅ **TLSOffload = true** - Hoạt động với Cloudflare Tunnel  
✅ **WebRTC = true** - Remote desktop/terminal tốt hơn  
✅ **allowedOrigin = true** - Không bị lỗi CORS  
✅ **localSessionRecording = true** - Ghi lại sessions  
✅ **NewAccounts = true** - Cho phép tạo accounts  
✅ **MariaDB** - Database đã cấu hình sẵn  

## 🔄 Nếu muốn giữ data cũ (migrate)

### Export data từ máy cũ:

```bash
# Backup volumes
docker compose down
docker run --rm -v meshcentral_meshcentral-data:/data -v ./backup:/backup alpine tar czf /backup/data.tar.gz -C /data .
docker run --rm -v meshcentral_mysql-data:/data -v ./backup:/backup alpine tar czf /backup/mysql.tar.gz -C /data .
```

### Import data vào máy mới:

```bash
# Copy folder backup/ sang máy mới
# Khởi động database trước
docker compose up -d mysql
docker compose down

# Restore volumes
docker run --rm -v meshcentral_meshcentral-data:/data -v ./backup:/backup alpine tar xzf /backup/data.tar.gz -C /data
docker run --rm -v meshcentral_mysql-data:/data -v ./backup:/backup alpine tar xzf /backup/mysql.tar.gz -C /data

# Khởi động lại
docker compose up -d
```

## 🐛 Troubleshooting nhanh

**Container không khởi động:**
```bash
docker compose logs meshcentral
```

**Agent không connect:**  
→ Reinstall agent mới từ web interface

**Không truy cập được web:**  
→ Kiểm tra Cloudflare Tunnel: `cloudflared tunnel info meshcentral`

**Database error:**  
→ Kiểm tra password trong config.json và docker-compose.yaml có khớp không

## 📦 Backup định kỳ (khuyến nghị)

```bash
# Tạo script backup tự động
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p backups/$DATE
docker run --rm -v meshcentral_meshcentral-data:/data -v ./backups/$DATE:/backup alpine tar czf /backup/data.tar.gz -C /data .
docker run --rm -v meshcentral_mysql-data:/data -v ./backups/$DATE:/backup alpine tar czf /backup/mysql.tar.gz -C /data .
echo "Backup completed: backups/$DATE"
EOF

chmod +x backup.sh
```

Chạy định kỳ với cron hoặc Task Scheduler.
