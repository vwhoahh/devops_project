# Blue-Green Deployment – E-Commerce DevOps Demo

## Architecture

```
User Browser
     │
     ▼
┌─────────────────────┐
│  NGINX Load Balancer│  ← Port 80 (proxy)
│   (nginx-proxy)     │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    ▼             ▼
┌────────┐   ┌─────────┐
│  BLUE  │   │  GREEN  │
│  v1    │   │   v2    │
│  :5001 │   │  :5002  │   ← Phase 5: Direct access ports
└────────┘   └─────────┘
```

## Access URLs

| Environment | URL | Description |
|-------------|-----|-------------|
| NGINX Proxy | http://localhost | Controlled by Phase 6 config |
| 🔵 Blue Direct | http://localhost:5001 | Always Blue (v1) |
| 🟢 Green Direct | http://localhost:5002 | Always Green (v2) |

---

## Quick Start (All 10 Phases in 3 Commands)

```powershell
# Phase 1-5: Start all containers
docker-compose up --build -d

# Phase 6-8: Switch to Green (zero-downtime deploy)
.\scripts\switch_to_green.ps1

# Phase 9: Rollback to Blue
.\scripts\rollback_to_blue.ps1
```

**OR run the full automated demonstration:**

```powershell
# Phase 10: Full demo (interactive walkthrough)
.\scripts\demo.ps1
```

---

## 10 Phases Overview

| Phase | Name | What Happens |
|-------|------|-------------|
| 1 | Environment Setup | Install Python, Docker, Git |
| 2 | Develop App | Build Flask e-commerce site |
| 3 | Two Versions | Create Blue (v1) and Green (v2) |
| 4 | Containerize | Build Docker images |
| 5 | Run Environments | Blue:5001, Green:5002 live |
| 6 | Configure NGINX | Traffic controlled at port 80 |
| 7 | Deploy to Green | New version ready in container |
| 8 | Switch Traffic | Users see Green (zero downtime) |
| 9 | Rollback | Revert to Blue instantly |
| 10 | Demonstration | End-to-end proof of concept |

📄 **Full details:** [PHASES.md](PHASES.md)

---

## Project Structure

```
blue-green-ecommerce-devops/
│
├── blue/app/
│   ├── app.py              ← Flask app (v1, 3 products)
│   ├── Dockerfile
│   ├── requirements.txt
│   └── templates/
│       ├── index.html
│       ├── cart.html
│       └── checkout.html
│
├── green/app/
│   ├── app.py              ← Flask app (v2, 4 products + sale)
│   ├── Dockerfile
│   ├── requirements.txt
│   └── templates/
│       ├── index.html      ← 🔥 Sale banner + Smartwatch
│       ├── cart.html
│       └── checkout.html
│
├── nginx/
│   ├── nginx.conf          ← Active routing config
│   ├── nginx-blue.conf     ← Phase 6: Always → Blue
│   └── nginx-green.conf    ← Phase 6: Always → Green
│
├── scripts/
│   ├── switch_to_green.ps1  ← Phase 7 & 8: Zero-downtime deploy
│   ├── rollback_to_blue.ps1 ← Phase 9: Rollback
│   └── demo.ps1             ← Phase 10: Full demonstration
│
├── docker-compose.yml
├── PHASES.md               ← Complete 10-phase guide
└── README.md
```

---

## Deployment Commands

### Phase 8 – Switch to Green (Zero-Downtime)

```powershell
.\scripts\switch_to_green.ps1
```

Manual:

```powershell
docker cp nginx/nginx-green.conf nginx-proxy:/etc/nginx/nginx.conf
docker exec nginx-proxy nginx -s reload
```

### Phase 9 – Rollback to Blue

```powershell
.\scripts\rollback_to_blue.ps1
```

Manual:

```powershell
docker cp nginx/nginx-blue.conf nginx-proxy:/etc/nginx/nginx.conf
docker exec nginx-proxy nginx -s reload
```

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `docker-compose up --build -d` | Build and start all containers |
| `docker-compose ps` | Show container status |
| `docker-compose logs -f` | Follow live logs |
| `docker stats` | Real-time resource usage |
| `docker exec nginx-proxy nginx -t` | Validate NGINX config |
| `docker exec nginx-proxy nginx -s reload` | Reload NGINX |
| `docker-compose down` | Stop all containers |
| `docker-compose down --rmi all` | Stop and delete images |

---

## Technology Stack

| Technology | Purpose |
|------------|---------|
| Python Flask | Web backend |
| HTML + Bootstrap 5 | Frontend UI |
| Docker | Containerization |
| Docker Compose | Multi-container orchestration |
| NGINX | Reverse proxy / load balancer |
| Git & GitHub | Version control |

---

## How Blue-Green Works

1. **Both containers always run** — Blue on 5001, Green on 5002
2. **NGINX** is the single entry point (port 80) — controls which container serves traffic
3. **Deploy** = copy new nginx config + `nginx -s reload` → zero downtime
4. **Rollback** = restore old nginx config + `nginx -s reload` → instant recovery
5. No container restarts. No downtime. No packet loss.

---

*Blue-Green Deployment DevOps Demonstration Project*
