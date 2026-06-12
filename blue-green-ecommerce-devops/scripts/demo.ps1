# ============================================================
#  Phase 10 - Project Demonstration Script
#  demo.ps1
#
#  Usage:  .\scripts\demo.ps1
#
#  This script walks through ALL 10 phases of Blue-Green
#  Deployment and demonstrates the full lifecycle:
#    Phase 5  - Show both environments running
#    Phase 6  - Show NGINX configuration
#    Phase 7  - Deploy Green version
#    Phase 8  - Switch traffic to Green
#    Phase 9  - Rollback to Blue
#    Phase 10 - Summary
# ============================================================

function Pause-WithMessage($msg) {
    Write-Host ""
    Write-Host "  [PAUSE]  $msg" -ForegroundColor Cyan
    Write-Host "     Press ENTER to continue..." -ForegroundColor Gray
    Read-Host | Out-Null
}

function Section($title) {
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor DarkCyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor DarkCyan
    Write-Host ""
}

function Step($num, $msg) {
    Write-Host "  [Step $num] $msg" -ForegroundColor Yellow
}

function Ok($msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Info($msg) {
    Write-Host "  [INFO]  $msg" -ForegroundColor White
}

# ─────────────────────────────────────────────────────────────
Write-Host ""
Write-Host ("*" * 60) -ForegroundColor Magenta
Write-Host "  BLUE-GREEN DEPLOYMENT - FULL DEMONSTRATION       " -ForegroundColor Magenta
Write-Host "  E-Commerce Web Application using Docker & NGINX   " -ForegroundColor Magenta
Write-Host ("*" * 60) -ForegroundColor Magenta

# ─────────────────────────────────────────────────────────────
Section "PHASE 1 - Environment Overview"
Info "Tools used in this project:"
Write-Host "    🐍 Python 3.11   - Flask web framework" -ForegroundColor White
Write-Host "    🐳 Docker        - Containerization" -ForegroundColor White
Write-Host "    🔁 Docker Compose - Multi-container orchestration" -ForegroundColor White
Write-Host "    [WEB] NGINX         - Load balancer / reverse proxy" -ForegroundColor White
Write-Host "    📦 Git / GitHub  - Version control" -ForegroundColor White

# ─────────────────────────────────────────────────────────────
Section "PHASE 2 & 3 - Application Versions"
Info "Two versions of the e-commerce store:"
Write-Host "    [BLUE] BLUE  (v1) - Blue Store:  Laptop, Smartphone, Headphones" -ForegroundColor Blue
Write-Host "    [GREEN] GREEN (v2) - Green Store: + Smartwatch + [SALE] 20% Sale" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
Section "PHASE 4 - Docker Images"
Step 1 "Listing Docker images..."
docker images --filter "reference=ecommerce*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
Write-Host ""
Ok "Both Docker images are built and ready"

# ─────────────────────────────────────────────────────────────
Section "PHASE 5 - Running Containers"
Step 2 "Checking container status..."
docker ps --filter "name=blue-app" --filter "name=green-app" --filter "name=nginx-proxy" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1
Write-Host ""
Info "Direct access URLs:"
Write-Host "    Blue  (v1): http://localhost:5001" -ForegroundColor Blue
Write-Host "    Green (v2): http://localhost:5002" -ForegroundColor Green
Write-Host "    NGINX proxy: http://localhost" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
Section "PHASE 6 - NGINX Configuration"
Step 3 "Current NGINX active routing:"
$active = docker exec nginx-proxy nginx -T 2>&1 | Select-String "proxy_pass"
Write-Host "    $active" -ForegroundColor White
Write-Host ""
Info "NGINX config files:"
Write-Host "    nginx/nginx-blue.conf  → Routes to Blue (v1)" -ForegroundColor Blue
Write-Host "    nginx/nginx-green.conf → Routes to Green (v2)" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────
Pause-WithMessage "Open http://localhost to see the CURRENT active environment"

# ─────────────────────────────────────────────────────────────
Section "PHASE 7 & 8 - Deploy & Switch to GREEN (Zero-Downtime)"
Step 4 "Copying nginx-green.conf into NGINX container..."
$greenConf = Join-Path $PSScriptRoot "..\nginx\nginx-green.conf"
$greenConf = (Resolve-Path $greenConf).Path
docker cp $greenConf nginx-proxy:/etc/nginx/nginx.conf
Ok "Config deployed"

Step 5 "Reloading NGINX (zero downtime - no container restart)..."
docker exec nginx-proxy nginx -s reload
Ok "NGINX reloaded!"

Write-Host ""
Write-Host "  [GREEN] GREEN (Version 2) is now LIVE!" -ForegroundColor Green
Write-Host "     Features: Smartwatch product + [SALE] 20% Discount Sale" -ForegroundColor White

Pause-WithMessage "Refresh http://localhost - you should see the GREEN store"

# ─────────────────────────────────────────────────────────────
Section "PHASE 9 - Rollback to BLUE (Simulating Failure)"
Write-Host "  [WARN]  Simulating: Green version has a critical bug!" -ForegroundColor Red
Write-Host "     Initiating emergency rollback to Blue..." -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Seconds 2

Step 6 "Copying nginx-blue.conf into NGINX container..."
$blueConf = Join-Path $PSScriptRoot "..\nginx\nginx-blue.conf"
$blueConf = (Resolve-Path $blueConf).Path
docker cp $blueConf nginx-proxy:/etc/nginx/nginx.conf
Ok "Rollback config deployed"

Step 7 "Reloading NGINX to complete rollback..."
docker exec nginx-proxy nginx -s reload
Ok "NGINX reloaded!"

Write-Host ""
Write-Host "  [BLUE] ROLLBACK COMPLETE - BLUE (Version 1) is now LIVE!" -ForegroundColor Blue
Write-Host "     System is stable and users are unaffected." -ForegroundColor White

Pause-WithMessage "Refresh http://localhost - you should see the BLUE store again"

# ─────────────────────────────────────────────────────────────
Section "PHASE 10 - Demonstration Summary"

Write-Host "  Phase  1  [OK]  Development environment ready" -ForegroundColor Green
Write-Host "  Phase  2  [OK]  E-commerce Flask app developed" -ForegroundColor Green
Write-Host "  Phase  3  [OK]  Blue (v1) and Green (v2) versions created" -ForegroundColor Green
Write-Host "  Phase  4  [OK]  Containerized with Docker" -ForegroundColor Green
Write-Host "  Phase  5  [OK]  Both containers running (Blue:5001, Green:5002)" -ForegroundColor Green
Write-Host "  Phase  6  [OK]  NGINX load balancer configured" -ForegroundColor Green
Write-Host "  Phase  7  [OK]  Green version deployed" -ForegroundColor Green
Write-Host "  Phase  8  [OK]  Zero-downtime traffic switch to Green" -ForegroundColor Green
Write-Host "  Phase  9  [OK]  Instant rollback to Blue demonstrated" -ForegroundColor Green
Write-Host "  Phase 10  [OK]  Complete demonstration finished" -ForegroundColor Green

Write-Host ""
Write-Host ("*" * 60) -ForegroundColor Magenta
Write-Host "  [YAY] BLUE-GREEN DEPLOYMENT DEMO COMPLETE!" -ForegroundColor Magenta
Write-Host ("*" * 60) -ForegroundColor Magenta
Write-Host ""
Write-Host "  Useful commands:" -ForegroundColor Gray
Write-Host "    docker-compose ps             - Show container status" -ForegroundColor Gray
Write-Host "    .\scripts\switch_to_green.ps1 - Deploy to Green" -ForegroundColor Gray
Write-Host "    .\scripts\rollback_to_blue.ps1 - Rollback to Blue" -ForegroundColor Gray
Write-Host "    docker-compose logs -f        - Follow container logs" -ForegroundColor Gray
Write-Host ""
