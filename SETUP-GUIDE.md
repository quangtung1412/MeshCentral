# MeshCentral Docker Setup - Chạy Phát Ăn Ngay! 🚀

## Yêu cầu
- Docker và Docker Compose
- Domain đã trỏ DNS (claymatium.com)
- Cloudflare Tunnel (tùy chọn cho remote access)

## Cài đặt nhanh

### 1. Clone hoặc copy toàn bộ thư mục này sang máy mới

```bash
git clone <your-repo>
cd MeshCentral
```

### 2. Chỉnh sửa config.json (nếu cần)

Mở file [config.json](config.json) và thay đổi:
- `cert`: Domain của bạn (hiện tại: claymatium.com)
- `certUrl`: Domain của bạn (hiện tại: claymatium.com:443)
- `mariaDB.password`: Đổi password mạnh hơn

### 3. Chỉnh sửa docker-compose.yaml (nếu cần)

Mở file [docker-compose.yaml](docker-compose.yaml) và đổi:
- `MYSQL_ROOT_PASSWORD`: Password cho MySQL root
- `MYSQL_PASSWORD`: Phải khớp với config.json

### 4. Khởi động

```bash
docker compose up -d
```

Xong! Server sẽ chạy tại:
- **HTTPS**: https://claymatium.com (qua Cloudflare Tunnel)
- **Local**: https://localhost:443

### 5. Tạo tài khoản admin

- Truy cập https://claymatium.com
- Tài khoản đầu tiên sẽ là **Site Administrator**

## Cấu trúc files quan trọng

```
MeshCentral/
├── docker-compose.yaml          # Cấu hình Docker (ports, volumes, database)
├── config.json                  # Cấu hình MeshCentral (QUAN TRỌNG!)
├── cloudflare-tunnel-setup.md   # Hướng dẫn setup Cloudflare Tunnel
└── agent-reconnect-guide.md     # Hướng dẫn kết nối agent
```

## Các file config được persist

✅ **config.json** - Mount từ host vào container (read-only)
✅ **Database data** - Lưu trong volume `mysql-data`
✅ **Certificates** - Lưu trong volume `meshcentral-data`
✅ **User files** - Lưu trong volume `meshcentral-files`

## Chuyển sang máy khác

### Cách 1: Copy toàn bộ project (Khuyến nghị)

```bash
# Trên máy cũ - backup volumes
docker compose down
docker run --rm -v meshcentral_meshcentral-data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/meshcentral-data.tar.gz -C /data .
docker run --rm -v meshcentral_mysql-data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/mysql-data.tar.gz -C /data .

# Copy thư mục backup/ sang máy mới

# Trên máy mới - restore volumes
docker compose up -d mysql
docker compose down
docker run --rm -v meshcentral_meshcentral-data:/data -v $(pwd)/backup:/backup alpine tar xzf /backup/meshcentral-data.tar.gz -C /data
docker run --rm -v meshcentral_mysql-data:/data -v $(pwd)/backup:/backup alpine tar xzf /backup/mysql-data.tar.gz -C /data
docker compose up -d
```

### Cách 2: Setup mới từ đầu (Đơn giản hơn)

Chỉ cần copy 3 files:
- `docker-compose.yaml`
- `config.json`
- `cloudflare-tunnel-setup.md` (nếu dùng)

Chạy `docker compose up -d` là xong!

## Config.json - Giải thích các setting quan trọng

```json
{
  "settings": {
    "cert": "claymatium.com",           // Domain của bạn
    "port": 443,                         // Port HTTPS
    "redirPort": 80,                     // Port HTTP redirect
    "TLSOffload": true,                  // BẮT BUỘC cho Cloudflare Tunnel!
    "WebRTC": true,                      // Bật WebRTC cho remote tốt hơn
    "mariaDB": {                         // Cấu hình database
      "host": "mysql",                   // Service name trong docker-compose
      "password": "meshcentral_password" // Phải khớp với docker-compose
    }
  },
  "domains": {
    "": {
      "NewAccounts": true,               // Cho phép tạo account mới
      "localSessionRecording": true,     // Ghi lại phiên remote
      "certUrl": "claymatium.com:443",   // Domain:port cho agents
      "allowedOrigin": true              // Cho phép CORS (cần cho Cloudflare)
    }
  }
}
```

## Troubleshooting

### Server không khởi động
```bash
docker compose logs meshcentral
```

### Agent không kết nối
Xem [agent-reconnect-guide.md](agent-reconnect-guide.md)

### Database error
```bash
# Kiểm tra MySQL
docker compose logs mysql

# Reset database (XÓA TẤT CẢ DỮ LIỆU!)
docker compose down -v
docker compose up -d
```

### Không truy cập được qua domain
1. Kiểm tra DNS đã trỏ đúng chưa
2. Kiểm tra Cloudflare Tunnel đang chạy: `cloudflared tunnel info meshcentral`
3. Xem [cloudflare-tunnel-setup.md](cloudflare-tunnel-setup.md)

## Commands hữu ích

```bash
# Xem logs real-time
docker compose logs -f meshcentral

# Xem logs agents
docker compose logs meshcentral | grep -i agent

# Restart service
docker compose restart meshcentral

# Dừng tất cả
docker compose down

# Dừng và XÓA DATA (cẩn thận!)
docker compose down -v

# Backup config
cp config.json config.json.backup

# Kiểm tra container đang chạy
docker compose ps
```

## Security Checklist

Trước khi production:

- [ ] Đổi `MYSQL_ROOT_PASSWORD` trong docker-compose.yaml
- [ ] Đổi `MYSQL_PASSWORD` trong cả docker-compose.yaml và config.json
- [ ] Đổi domain trong config.json thành domain thật của bạn
- [ ] Bật 2FA cho admin accounts
- [ ] Set `NewAccounts: false` sau khi tạo xong accounts
- [ ] Backup định kỳ volumes

## Cloudflare Settings (bắt buộc)

Trong Cloudflare Dashboard:

**SSL/TLS:**
- SSL/TLS encryption mode: **Full** (không phải Strict)
- Always Use HTTPS: **On**

**Network:**
- WebSockets: **On** ← QUAN TRỌNG!
- gRPC: **On**

## Support

- Documentation: https://ylianst.github.io/MeshCentral/
- GitHub Issues: https://github.com/Ylianst/MeshCentral/issues
- Reddit: https://www.reddit.com/r/MeshCentral/

## Các ports cần mở

- **443**: HTTPS Web Interface + Agents
- **80**: HTTP redirect
- **4433**: Intel AMT (tùy chọn)

Nếu dùng Cloudflare Tunnel, chỉ cần mở ports **trên container**, không cần mở trên firewall.
