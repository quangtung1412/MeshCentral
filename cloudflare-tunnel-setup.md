# Setup Cloudflare Tunnel cho MeshCentral

## Bước 1: Cài đặt Cloudflared

### Windows:
```powershell
# Download và cài đặt cloudflared
winget install --id Cloudflare.cloudflared
```

Hoặc download từ: https://github.com/cloudflare/cloudflared/releases

## Bước 2: Đăng nhập Cloudflare

```powershell
cloudflared tunnel login
```

Trình duyệt sẽ mở và yêu cầu đăng nhập Cloudflare. Chọn domain `claymatium.com`.

## Bước 3: Tạo Tunnel

```powershell
cloudflared tunnel create meshcentral
```

Lưu lại Tunnel ID được tạo ra.

## Bước 4: Tạo file config

Tạo file `config.yml` (thường ở `C:\Users\<username>\.cloudflared\config.yml`):

```yaml
tunnel: <TUNNEL_ID>
credentials-file: C:\Users\<username>\.cloudflared\<TUNNEL_ID>.json

ingress:
  # Route cho MeshCentral HTTPS
  - hostname: claymatium.com
    service: https://localhost:443
    originRequest:
      noTLSVerify: true
      
  # Route cho MeshCentral HTTP (redirect)
  - hostname: claymatium.com
    service: http://localhost:80
    originRequest:
      noTLSVerify: true
      
  # Catch-all rule (bắt buộc)
  - service: http_status:404
```

## Bước 5: Route DNS

```powershell
cloudflared tunnel route dns meshcentral claymatium.com
```

Lệnh này sẽ tự động tạo CNAME record trên Cloudflare DNS.

## Bước 6: Chạy Tunnel

### Chạy thử:
```powershell
cloudflared tunnel run meshcentral
```

### Chạy như Windows Service (khuyến nghị):
```powershell
cloudflared service install
```

Tunnel sẽ tự động khởi động cùng Windows.

## Bước 7: Restart MeshCentral

```powershell
docker compose restart meshcentral
```

## Bước 8: Kiểm tra

1. Truy cập: https://claymatium.com
2. Tạo tài khoản admin
3. Test remote desktop/terminal

## Troubleshooting

### Kiểm tra tunnel status:
```powershell
cloudflared tunnel info meshcentral
```

### Xem logs:
```powershell
cloudflared tunnel run meshcentral --loglevel debug
```

### Nếu gặp lỗi certificate:
- Đảm bảo `noTLSVerify: true` trong config.yml
- Restart cloudflared service

## Cấu hình nâng cao cho Remote Desktop tốt hơn

Nếu muốn performance tốt hơn cho remote desktop, thêm vào `originRequest`:

```yaml
ingress:
  - hostname: claymatium.com
    service: https://localhost:443
    originRequest:
      noTLSVerify: true
      connectTimeout: 30s
      noHappyEyeballs: false
      http2Origin: true
```

## Cloudflare Settings khuyến nghị

Trong Cloudflare Dashboard > SSL/TLS:
- **SSL/TLS encryption mode**: Full (not Strict)
- **Always Use HTTPS**: On
- **Minimum TLS Version**: 1.2

Trong Cloudflare Dashboard > Network:
- **WebSockets**: On (quan trọng cho remote features)
- **gRPC**: On

## Alternative: Docker Compose với Cloudflared

Nếu muốn chạy cloudflared cùng với MeshCentral trong Docker, thêm vào docker-compose.yaml:

```yaml
  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=<YOUR_TUNNEL_TOKEN>
    networks:
      - meshcentral-network
```

Để lấy TUNNEL_TOKEN:
```powershell
cloudflared tunnel token meshcentral
```
