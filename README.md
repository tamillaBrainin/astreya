# astrobot

A new Flutter project.

## Deploy To DigitalOcean Droplet (Docker)

This repository includes production files for running AstroBot on a DigitalOcean Droplet using Docker Compose.

### Included files

- `Dockerfile` builds Flutter web and serves it via Nginx
- `deploy/nginx.conf` enables SPA fallback for Flutter routes
- `docker-compose.prod.yml` runs the web container on port 80
- `.env.prod.example` stores production API URL config

### Current deployment layout

- Caddy serves the built Flutter web app from `/srv` on the droplet
- Docker Compose is used for the backend service
- The backend build context in `docker-compose.prod.yml` points to the sibling backend repo:

```yaml
backend:
	build:
		context: ../astrologyAnalyzer/astrologyAnylizer
```

- For the current chart flow, `/chart` prioritizes the main natal interpretation and intentionally leaves the optional interpretation maps empty when needed for responsiveness

### 1) Buy/Create a Droplet

In DigitalOcean, create a Droplet with these baseline settings:

- Ubuntu 24.04 LTS
- Basic plan (at least 1 GB RAM)
- Authentication: SSH key (recommended)
- Open ports 22 and 80 in firewall rules

### 2) SSH into the Droplet

```bash
ssh root@YOUR_DROPLET_IP
```

### 3) Install Docker + Compose plugin

```bash
apt update && apt upgrade -y
apt install -y ca-certificates curl gnupg git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker
```

### 4) Pull your project and configure env

```bash
git clone https://github.com/YOUR_GITHUB_USER/YOUR_REPO.git
cd YOUR_REPO
cp .env.prod.example .env.prod
```

Edit `.env.prod` and set your real backend URL:

```text
API_BASE_URL=https://api.yourdomain.com
```

### 5) Build and run in Docker

```bash
docker compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
```

Verify:

```bash
docker compose -f docker-compose.prod.yml ps
docker logs astrobot-web --tail 100
```

Open `http://YOUR_DROPLET_IP`.

### 6) Deploy updates

```bash
git pull
docker compose --env-file .env.prod -f docker-compose.prod.yml up -d --build
```

### Optional: Domain + HTTPS

Point your domain A record to the Droplet IP, then terminate TLS with Caddy or Nginx + Certbot.

## Getting Started

This project is a starting point for a Flutter application.

## Local Backend Note (Claude API Key)

If transit or natal AI interpretation falls back, backend may be running without a Claude API key.

Set key in CMD before backend start:

```cmd
cd /d c:\dev\astrologyAnalyzer\astrologyAnylizer
set "CLAUDE_API_KEY=YOUR_REAL_KEY"
mvnw.cmd spring-boot:run "-Dspring-boot.run.arguments=--server.port=8082"
```

If backend is already running in another CMD window:

```cmd
:: CMD #1 (where backend is running)
netstat -ano | findstr :8082
taskkill /F /PID <PID_FROM_8082>

:: CMD #2 (set key and run backend in the SAME window)
cd /d c:\dev\astrologyAnalyzer\astrologyAnylizer
set "CLAUDE_API_KEY=YOUR_REAL_KEY"
echo %CLAUDE_API_KEY%
mvnw.cmd spring-boot:run "-Dspring-boot.run.arguments=--server.port=8082"
```

Important: backend must be started in the same CMD window where `set "CLAUDE_API_KEY=..."` was executed.

Persist key for new terminal sessions:

```cmd
setx CLAUDE_API_KEY "YOUR_REAL_KEY"
```

For full local verification steps, see [tests.md](tests.md).

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
