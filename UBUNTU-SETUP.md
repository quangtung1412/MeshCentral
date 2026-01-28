# Setup trên Ubuntu Linux

## Yêu cầu hệ thống

- Ubuntu 20.04+ (hoặc Debian 11+)
- Docker và Docker Compose
- Domain đã trỏ DNS về server

## Cài đặt Docker trên Ubuntu

```bash
# Update packages
sudo apt update
sudo apt upgrade -y

# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user vào docker group (không cần sudo)
sudo usermod -aG docker $USER

# Logout và login lại để apply group changes
# hoặc chạy: newgrp docker

# Cài đặt Docker Compose (nếu chưa có)
sudo apt install docker-compose-plugin -y

# Kiểm tra
docker --version
docker compose version
```

## Setup MeshCentral

### 1. Clone repository

```bash
git clone <your-repo-url>
cd MeshCentral
```

### 2. Tạo file .env

```bash
# Copy template
cp .env.example .env

# Sửa file .env
nano .env
```

**Sửa các giá trị sau trong .env:**
```env
# Domain của bạn
HOSTNAME=your-domain.com
REVERSE_PROXY=your-domain.com

# Database passwords (BẮT BUỘC ĐỔI!)
MYSQL_ROOT_PASSWORD=your_secure_root_password_here
MYSQL_PASSWORD=your_secure_db_password_here
```

Lưu file: `Ctrl+O`, Enter, `Ctrl+X`

### 3. Generate config

```bash
# Cho phép execute script
chmod +x generate-config.sh

# Chạy script
./generate-config.sh
```

Output:
```
✅ Generated config.runtime.json from config.json template
Now run: docker compose up -d
```

### 4. Khởi động services

```bash
# Start trong background
docker compose up -d

# Xem logs
docker compose logs -f meshcentral
```

### 5. Kiểm tra

```bash
# Xem containers đang chạy
docker compose ps

# Output mong đợi:
# NAME                IMAGE                         STATUS
# meshcentral         meshcentral:latest-mysql      Up
# meshcentral-mysql   mariadb:10.11                 Up (healthy)
```

## Setup Cloudflare Tunnel (cho remote access)

### 1. Cài đặt cloudflared

```bash
# Download cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Cài đặt
sudo dpkg -i cloudflared-linux-amd64.deb

# Kiểm tra
cloudflared --version
```

### 2. Đăng nhập Cloudflare

```bash
cloudflared tunnel login
```

Browser sẽ mở, chọn domain của bạn.

### 3. Tạo tunnel

```bash
# Tạo tunnel
cloudflared tunnel create meshcentral

# Lưu lại Tunnel ID được hiển thị
```

### 4. Tạo config file

```bash
# Tạo thư mục config
mkdir -p ~/.cloudflared

# Tạo config
nano ~/.cloudflared/config.yml
```

Nội dung:
```yaml
tunnel: <TUNNEL_ID_FROM_STEP_3>
credentials-file: /home/<your-username>/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: your-domain.com
    service: https://localhost:443
    originRequest:
      noTLSVerify: true
      
  - service: http_status:404
```

### 5. Route DNS

```bash
cloudflared tunnel route dns meshcentral your-domain.com
```

### 6. Chạy tunnel

**Test run:**
```bash
cloudflared tunnel run meshcentral
```

**Chạy như service (khuyến nghị):**
```bash
# Install service
sudo cloudflared service install

# Start service
sudo systemctl start cloudflared

# Enable auto-start
sudo systemctl enable cloudflared

# Xem status
sudo systemctl status cloudflared
```

## Firewall (UFW)

Nếu dùng UFW, mở các ports cần thiết:

```bash
# Cho phép SSH (quan trọng!)
sudo ufw allow 22/tcp

# Nếu KHÔNG dùng Cloudflare Tunnel:
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Kiểm tra
sudo ufw status
```

**Lưu ý:** Nếu dùng Cloudflare Tunnel, KHÔNG CẦN mở port 80/443 vì traffic đi qua tunnel.

## Commands thường dùng

### Docker

```bash
# Xem logs real-time
docker compose logs -f meshcentral

# Restart service
docker compose restart meshcentral

# Stop services
docker compose down

# Stop và XÓA DATA (cẩn thận!)
docker compose down -v

# Xem resource usage
docker stats
```

### Cloudflare Tunnel

```bash
# Xem tunnel info
cloudflared tunnel info meshcentral

# Xem logs
sudo journalctl -u cloudflared -f

# Restart service
sudo systemctl restart cloudflared
```

### System

```bash
# Xem disk usage
df -h

# Xem memory
free -h

# Xem processes
htop
```

## Backup

### Backup volumes

```bash
# Stop containers
docker compose down

# Backup
docker run --rm \
  -v meshcentral_meshcentral-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/meshcentral-data-$(date +%Y%m%d).tar.gz -C /data .

docker run --rm \
  -v meshcentral_mysql-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/mysql-data-$(date +%Y%m%d).tar.gz -C /data .

# Start lại
docker compose up -d
```

### Backup .env

```bash
# Encrypt backup
gpg -c .env

# File .env.gpg sẽ được tạo (encrypted)
```

### Auto backup với cron

```bash
# Tạo backup script
cat > /home/$USER/backup-meshcentral.sh << 'EOF'
#!/bin/bash
cd /path/to/MeshCentral
docker compose down
docker run --rm -v meshcentral_meshcentral-data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/data-$(date +%Y%m%d).tar.gz -C /data .
docker run --rm -v meshcentral_mysql-data:/data -v $(pwd)/backup alpine tar czf /backup/mysql-$(date +%Y%m%d).tar.gz -C /data .
docker compose up -d
# Xóa backup cũ hơn 7 ngày
find backup/ -name "*.tar.gz" -mtime +7 -delete
EOF

# Cho phép execute
chmod +x /home/$USER/backup-meshcentral.sh

# Setup cron (chạy 2am mỗi ngày)
crontab -e
# Thêm dòng:
# 0 2 * * * /home/$USER/backup-meshcentral.sh >> /home/$USER/backup.log 2>&1
```

## Troubleshooting

### Permission denied khi chạy docker

```bash
# Thêm user vào docker group
sudo usermod -aG docker $USER

# Logout và login lại
exit
```

### Port already in use

```bash
# Xem process đang dùng port
sudo netstat -tulpn | grep :443

# Kill process nếu cần
sudo kill -9 <PID>
```

### Out of disk space

```bash
# Xem disk usage
df -h

# Cleanup docker
docker system prune -a --volumes

# Xóa logs cũ
sudo journalctl --vacuum-time=7d
```

### Container không khởi động

```bash
# Xem full logs
docker compose logs meshcentral

# Recreate containers
docker compose down -v
docker compose up -d
```

## Security Checklist

- [ ] Đổi tất cả passwords trong .env
- [ ] Setup UFW firewall
- [ ] Chỉ mở ports cần thiết
- [ ] Dùng Cloudflare Tunnel thay vì expose ports
- [ ] Enable auto-updates: `sudo apt install unattended-upgrades`
- [ ] Setup fail2ban: `sudo apt install fail2ban`
- [ ] Backup .env vào nơi an toàn
- [ ] Setup auto-backup với cron
- [ ] Enable 2FA cho MeshCentral admin
- [ ] Monitor logs: `docker compose logs -f`

## Cập nhật system

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker compose pull
docker compose up -d

# Cleanup old images
docker image prune -a
```
