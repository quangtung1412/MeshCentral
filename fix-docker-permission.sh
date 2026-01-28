#!/bin/bash
# Fix Docker permission denied trên Ubuntu

echo "🔧 Fixing Docker permission..."

# Thêm user vào docker group
sudo usermod -aG docker $USER

echo "✅ Added $USER to docker group"
echo ""
echo "⚠️  Bạn cần làm 1 trong 2 cách sau:"
echo ""
echo "Cách 1: Logout và login lại (khuyến nghị)"
echo "  exit"
echo ""
echo "Cách 2: Apply group changes ngay (không cần logout)"
echo "  newgrp docker"
echo ""
echo "Sau đó chạy lại: docker compose up -d"
