# Hướng dẫn kết nối lại Agent sau khi sửa config

## Trên máy Client Windows:

### Cách 1: Restart Agent Service (nhanh)
```powershell
# Chạy PowerShell as Administrator
Restart-Service -Name "Mesh Agent"
```

### Cách 2: Reinstall Agent (khuyến nghị)
1. Gỡ agent cũ:
```powershell
# PowerShell as Administrator
Stop-Service "Mesh Agent"
& "C:\Program Files\Mesh Agent\MeshAgent.exe" -uninstall
```

2. Tải agent mới từ MeshCentral:
   - Truy cập: https://claymatium.com
   - Đăng nhập
   - Vào **My Devices**
   - Click **+ Add Agent**
   - Download và chạy file mới

## Kiểm tra Agent đã kết nối

### Trên Server:
```powershell
docker compose logs -f meshcentral | Select-String "agent"
```

Bạn sẽ thấy:
- "Agent connected" hoặc
- Device xuất hiện trong web interface

### Trên Client:
```powershell
# Kiểm tra service đang chạy
Get-Service "Mesh Agent"

# Xem log của agent (nếu có)
Get-Content "C:\Program Files\Mesh Agent\MeshAgent.log" -Tail 20
```

## Troubleshooting

### Nếu vẫn không kết nối được:

1. **Kiểm tra Cloudflare Tunnel đang chạy:**
```powershell
cloudflared tunnel info meshcentral
```

2. **Kiểm tra port đang mở:**
```powershell
docker compose ps
# Đảm bảo 443:443 và 80:80 đang exposed
```

3. **Test kết nối từ client:**
```powershell
Test-NetConnection claymatium.com -Port 443
curl https://claymatium.com
```

4. **Xem logs real-time:**
```powershell
docker compose logs -f meshcentral
```

### Các lỗi thường gặp:

**"Agent bad web cert hash"** → Đã fix bằng TLSOffload=true, reinstall agent

**"Connection timeout"** → Cloudflare tunnel chưa chạy hoặc cấu hình sai

**"Invalid origin"** → Đã fix với allowedOrigin=true

**"WebSocket error"** → Bật WebSockets trong Cloudflare Dashboard

## Cấu hình Docker Compose đã được update

File docker-compose.yaml hiện tại đã có:
- ✅ HOSTNAME=claymatium.com
- ✅ REVERSE_PROXY=claymatium.com
- ✅ ALLOWED_ORIGIN=true
- ✅ WEBRTC=true

Và trong config.json:
- ✅ TLSOffload=true (cho Cloudflare)
- ✅ certUrl=claymatium.com:443
