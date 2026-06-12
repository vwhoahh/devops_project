# ============================================================
#  Phase 7 - Deploy Updated Application to Green
#  switch_to_green.ps1
#
#  Usage:  .\scripts\switch_to_green.ps1
#
#  What this script does:
#    1. Copies nginx-green.conf into the running NGINX container
#    2. Hot-reloads NGINX (zero downtime - no restart needed)
#    3. Traffic is now routed to Green (Version 2)
# ============================================================

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Phase 7 & 8 - Switch Traffic to GREEN (v2)   " -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1 - Check containers are running
Write-Host "[1/3] Checking container status..." -ForegroundColor Yellow
$nginxRunning = docker ps --filter "name=nginx-proxy" --filter "status=running" -q
if (-not $nginxRunning) {
    Write-Host "  [ERROR] ERROR: nginx-proxy container is not running!" -ForegroundColor Red
    Write-Host "     Please start containers first: docker-compose up -d" -ForegroundColor Red
    exit 1
}
$greenRunning = docker ps --filter "name=green-app" --filter "status=running" -q
if (-not $greenRunning) {
    Write-Host "  [ERROR] ERROR: green-app container is not running!" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] All containers are running" -ForegroundColor Green

# Step 2 - Copy Green NGINX config into the container
Write-Host ""
Write-Host "[2/3] Deploying Green NGINX configuration..." -ForegroundColor Yellow
$confPath = Join-Path $PSScriptRoot "..\nginx\nginx-green.conf"
$confPath = (Resolve-Path $confPath).Path
docker cp $confPath nginx-proxy:/etc/nginx/nginx.conf
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] ERROR: Failed to copy nginx-green.conf" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] nginx-green.conf copied to container" -ForegroundColor Green

# Step 3 - Hot reload NGINX (zero downtime)
Write-Host ""
Write-Host "[3/3] Hot-reloading NGINX (zero downtime)..." -ForegroundColor Yellow
docker exec nginx-proxy nginx -s reload
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] ERROR: NGINX reload failed" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] NGINX reloaded successfully" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  [OK] TRAFFIC NOW ROUTED TO → GREEN (Version 2)  " -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  [WEB] Open browser: http://localhost" -ForegroundColor White
Write-Host "  [GREEN] You should see: Green Store - Version 2" -ForegroundColor White
Write-Host "  [SALE] With: 20% Discount Sale banner + Smartwatch" -ForegroundColor White
Write-Host ""
Write-Host "  Direct access:" -ForegroundColor Gray
Write-Host "    Blue  (v1): http://localhost:5001" -ForegroundColor Blue
Write-Host "    Green (v2): http://localhost:5002" -ForegroundColor Green
Write-Host ""
Write-Host "  To rollback: .\scripts\rollback_to_blue.ps1" -ForegroundColor Yellow
Write-Host ""
