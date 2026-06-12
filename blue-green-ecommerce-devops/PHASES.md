# Blue-Green Deployment – 10 Phase Project Guide

This document walks through every phase of the project from environment setup to live demonstration.

---

## Phase 1 — Project Environment Setup

**Goal:** Prepare all tools needed to build, containerize, and deploy the application.

### Tools Required

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.11+ | Flask web framework |
| Docker Desktop | Latest | Container engine |
| Docker Compose | v2+ | Multi-container orchestration |
| NGINX | 1.25 (via Docker) | Load balancer |
| Git | Latest | Version control |

### Setup Steps

```powershell
# Verify installations
python --version
docker --version
docker compose version
git --version
```

### Create project folder and initialize Git

```powershell
mkdir blue-green-ecommerce-devops
cd blue-green-ecommerce-devops
git init
git add .
git commit -m "Phase 1: Initial project setup"
```

**Output:** Development environment ready with all tools installed.

---

## Phase 2 — Develop the E-Commerce Web Application

**Goal:** Build a working Flask-based e-commerce website.

### Application Pages

| Page | Route | Description |
|------|-------|-------------|
| Home | `/` | Product listing |
| Cart | `/cart` | Shopping cart |
| Checkout | `/checkout` | Order form |

### Example Products

```
Laptop       ₹55,000
Smartphone   ₹30,000
Headphones    ₹3,000
```

### Key File

```
blue/app/app.py   – Flask routes + product data
```

**Output:** Flask app running locally, accessible in browser.

---

## Phase 3 — Create Two Versions of the Application

**Goal:** Create Blue (current) and Green (updated) versions.

### Differences Between Versions

| Feature | 🔵 Blue (v1) | 🟢 Green (v2) |
|---------|-------------|--------------|
| Title | Blue Store – Version 1 | Green Store – Version 2 |
| Environment badge | `BLUE` | `GREEN` |
| Products | 3 products | 4 products (+ Smartwatch) |
| Sale Banner | ❌ | 🔥 20% Discount Sale |
| Theme color | Blue (`#1565C0`) | Green (`#2E7D32`) |

### Code Location

```
blue/app/   – Version 1 (current production)
green/app/  – Version 2 (new release)
```

**Output:** Two fully working versions of the e-commerce website.

---

## Phase 4 — Containerize with Docker

**Goal:** Package both app versions inside Docker containers.

### Dockerfile Structure

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

### Build Images Manually

```powershell
# Build Blue image
docker build -t ecommerce-blue:v1 ./blue/app

# Build Green image
docker build -t ecommerce-green:v2 ./green/app

# List images
docker images
```

**Output:** `ecommerce-blue:v1` and `ecommerce-green:v2` Docker images ready.

---

## Phase 5 — Deploy Blue and Green Environments

**Goal:** Run both containers simultaneously on separate ports.

### Port Mapping

| Container | Internal Port | Host Port | URL |
|-----------|--------------|-----------|-----|
| blue-app | 5000 | **5001** | http://localhost:5001 |
| green-app | 5000 | **5002** | http://localhost:5002 |
| nginx-proxy | 80 | **80** | http://localhost |

### Start All Containers

```powershell
docker-compose up --build -d
docker-compose ps
```

### Direct Environment Access

```powershell
# Visit Blue directly (bypass NGINX)
Start-Process "http://localhost:5001"

# Visit Green directly (bypass NGINX)
Start-Process "http://localhost:5002"

# Visit through NGINX (load balancer)
Start-Process "http://localhost"
```

**Output:** Both Blue (port 5001) and Green (port 5002) environments running simultaneously.

---

## Phase 6 — Configure NGINX Load Balancer

**Goal:** Route all user traffic through NGINX to control which environment they see.

### Architecture

```
User → http://localhost → NGINX (port 80) → Blue (5000) OR Green (5000)
```

### NGINX Config Files

| File | Routes to | Used by |
|------|-----------|---------|
| `nginx/nginx.conf` | Configurable (edit the proxy_pass line) | Main config |
| `nginx/nginx-blue.conf` | Blue (v1) | `rollback_to_blue.ps1` |
| `nginx/nginx-green.conf` | Green (v2) | `switch_to_green.ps1` |

### Verify NGINX is running

```powershell
# Check NGINX health
curl http://localhost/health

# Check NGINX logs
docker exec nginx-proxy tail -f /var/log/nginx/access.log
```

**Output:** All user traffic passes through NGINX at port 80.

---

## Phase 7 — Deploy Updated Application to Green

**Goal:** Make the Green environment live with the new version.

### What Changed in Green (v2)

- ✅ New product: **Smartwatch – ₹8,000**
- ✅ **🔥 20% Discount Sale** banner
- ✅ Improved UI with green color theme
- ✅ Cart shows discount pricing (₹96,000 → ₹76,800)

### Deploy Green (Zero-Downtime)

```powershell
.\scripts\switch_to_green.ps1
```

**OR manually:**

```powershell
# Copy green NGINX config into container
docker cp nginx/nginx-green.conf nginx-proxy:/etc/nginx/nginx.conf

# Hot-reload NGINX (no downtime)
docker exec nginx-proxy nginx -s reload
```

**Output:** Green environment is now the active production environment.

---

## Phase 8 — Switch Traffic from Blue to Green

**Goal:** Redirect all users from the old version to the new version without any downtime.

### Traffic Flow Change

```
BEFORE:  User → NGINX → Blue (v1)
AFTER:   User → NGINX → Green (v2)
```

### Automated Switch

```powershell
.\scripts\switch_to_green.ps1
```

### Verify the Switch

1. Open `http://localhost` in browser
2. You should see **Green Store – Version 2**
3. Look for the **🔥 20% Discount Sale** banner
4. Check **Environment: GREEN** badge in top-right

**Output:** Users see the updated Green store (Version 2) — zero downtime.

---

## Phase 9 — Rollback Mechanism

**Goal:** Instantly revert to the stable Blue version if the Green version has problems.

### When to Rollback

- Green version has bugs or errors
- Performance issues detected
- Failed health checks

### Rollback Command

```powershell
.\scripts\rollback_to_blue.ps1
```

### Manual Rollback

```powershell
# Copy blue NGINX config into container
docker cp nginx/nginx-blue.conf nginx-proxy:/etc/nginx/nginx.conf

# Hot-reload NGINX
docker exec nginx-proxy nginx -s reload
```

### Verify Rollback

1. Open `http://localhost` in browser
2. You should see **Blue Store – Version 1**
3. Check **Environment: BLUE** badge in top-right

**Output:** System instantly reverted to Blue (Version 1). Users unaffected.

---

## Phase 10 — Full Project Demonstration

**Goal:** Show the complete Blue-Green deployment lifecycle end-to-end.

### Run Full Demo Script

```powershell
.\scripts\demo.ps1
```

This script automatically:
1. Shows environment overview
2. Lists Docker images
3. Checks running containers
4. Shows NGINX routing
5. Switches to Green (zero-downtime)
6. Pauses for browser verification
7. Simulates failure → rollback to Blue
8. Prints complete phase summary

### Manual Demonstration Flow

```powershell
# STEP 1: Start all containers
docker-compose up --build -d

# STEP 2: Verify Blue is live
Start-Process "http://localhost"  # Should show Blue Store v1

# STEP 3: Deploy Green
.\scripts\switch_to_green.ps1

# STEP 4: Verify Green is live
Start-Process "http://localhost"  # Should show Green Store v2

# STEP 5: Rollback
.\scripts\rollback_to_blue.ps1

# STEP 6: Confirm rollback
Start-Process "http://localhost"  # Should show Blue Store v1 again
```

### Useful Commands

| Command | Description |
|---------|-------------|
| `docker-compose ps` | Show container status |
| `docker-compose logs -f` | Follow all logs |
| `docker stats` | Real-time container resource usage |
| `docker exec nginx-proxy nginx -t` | Test NGINX config |
| `docker exec nginx-proxy nginx -s reload` | Reload NGINX |
| `docker-compose down` | Stop all containers |
| `docker-compose down --rmi all` | Stop and remove images |

---

## Project File Structure

```
blue-green-ecommerce-devops/
│
├── blue/app/
│   ├── app.py                 Phase 2: Flask app v1
│   ├── Dockerfile             Phase 4: Container definition
│   ├── requirements.txt
│   └── templates/
│       ├── index.html         Phase 3: Blue home page
│       ├── cart.html
│       └── checkout.html
│
├── green/app/
│   ├── app.py                 Phase 3: Flask app v2 + sale
│   ├── Dockerfile             Phase 4: Container definition
│   ├── requirements.txt
│   └── templates/
│       ├── index.html         Phase 3: Green home + banner
│       ├── cart.html          (with discount pricing)
│       └── checkout.html
│
├── nginx/
│   ├── nginx.conf             Phase 6: Active routing config
│   ├── nginx-blue.conf        Phase 6: Always → Blue
│   └── nginx-green.conf       Phase 6: Always → Green
│
├── scripts/
│   ├── switch_to_green.ps1   Phase 7 & 8: Zero-downtime deploy
│   ├── rollback_to_blue.ps1  Phase 9: Emergency rollback
│   └── demo.ps1              Phase 10: Full demonstration
│
├── docker-compose.yml         Phase 5: Orchestration
├── PHASES.md                  This file
└── README.md                  Quick-start guide
```

---

*Blue-Green Deployment DevOps Project — Complete 10-Phase Guide*
