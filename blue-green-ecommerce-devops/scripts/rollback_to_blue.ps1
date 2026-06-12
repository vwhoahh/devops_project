# ============================================================
#  Phase 9 - Rollback Mechanism
#  rollback_to_blue.ps1
#
#  Usage:  .\scripts\rollback_to_blue.ps1
#
#  What this script does:
#    1. Copies nginx-blue.conf into the running NGINX container
#    2. Hot-reloads NGINX (zero downtime - no restart needed)
#    3. Traffic is instantly reverted to Blue (Version 1)
#
#  Use this if the Green version has issues or bugs.
# ============================================================

Write-Host ""
Write-Host "================================================" -ForegroundColor Magenta
Write-Host "  Phase 9 - ROLLBACK to BLUE (Version 1)       " -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Magenta
Write-Host ""

# Step 1 - Check containers are running
Write-Host "[1/3] Checking container status..." -ForegroundColor Yellow
$nginxRunning = docker ps --filter "name=nginx-proxy" --filter "status=running" -q
if (-not $nginxRunning) {
    Write-Host "  [ERROR] ERROR: nginx-proxy container is not running!" -ForegroundColor Red
    Write-Host "     Please start containers first: docker-compose up -d" -ForegroundColor Red
    exit 1
}
$blueRunning = docker ps --filter "name=blue-app" --filter "status=running" -q
if (-not $blueRunning) {
    Write-Host "  [ERROR] ERROR: blue-app container is not running!" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] All containers are running" -ForegroundColor Green

# Step 2 - Copy Blue NGINX config into the container
Write-Host ""
Write-Host "[2/3] Deploying Blue NGINX configuration..." -ForegroundColor Yellow
$confPath = Join-Path $PSScriptRoot "..\nginx\nginx-blue.conf"
$confPath = (Resolve-Path $confPath).Path
docker cp $confPath nginx-proxy:/etc/nginx/nginx.conf
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERROR] ERROR: Failed to copy nginx-blue.conf" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] nginx-blue.conf copied to container" -ForegroundColor Green

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
Write-Host "================================================" -ForegroundColor Blue
Write-Host "  [OK] ROLLBACK COMPLETE → BLUE (Version 1) LIVE  " -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  [WEB] Open browser: http://localhost" -ForegroundColor White
Write-Host "  [BLUE] You should see: Blue Store - Version 1" -ForegroundColor White
Write-Host "  [OK] System is stable and recovered" -ForegroundColor White
Write-Host ""
Write-Host "  Direct access:" -ForegroundColor Gray
Write-Host "    Blue  (v1): http://localhost:5001" -ForegroundColor Blue
Write-Host "    Green (v2): http://localhost:5002" -ForegroundColor Green
Write-Host ""
Write-Host "  To switch to Green again: .\scripts\switch_to_green.ps1" -ForegroundColor Yellow
Write-Host ""
