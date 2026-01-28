# Generate config.json từ template + .env
# Chạy script này trước khi docker compose up

if (!(Test-Path .env)) {
    Write-Error ".env file not found! Copy .env.example to .env first"
    exit 1
}

# Load .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        Set-Variable -Name $name -Value $value
    }
}

# Read template
$config = Get-Content config.json -Raw

# Replace placeholders
$config = $config -replace 'HOSTNAME_PLACEHOLDER', $HOSTNAME
$config = $config -replace 'DB_PASSWORD_PLACEHOLDER', $MYSQL_PASSWORD
$config = $config -replace 'NEW_ACCOUNTS_PLACEHOLDER', $ALLOW_NEW_ACCOUNTS.ToLower()

# Write runtime config
$config | Set-Content config.runtime.json

Write-Host "✅ Generated config.runtime.json from config.json template"
Write-Host "Now run: docker compose up -d"
