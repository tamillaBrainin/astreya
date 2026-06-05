# Deployment Session Log — 2026-05-29/30

## Summary
- Deployed AstroBot (UI) and astrologyAnylizer (backend) to DigitalOcean Droplet
- Set up Docker Compose for both services
- Switched to Caddy for HTTPS and static web serving
- Configured Cloudflare/DigitalOcean DNS for astreya.space and www.astreya.space
- Troubleshot DNS, SSL, and container issues

## Step-by-step Actions

### SSH Connection Command
To connect to your Droplet from your PC:

```
ssh -i "C:\Users\zibit\.ssh\id_ed25519_do" root@164.92.192.21
```

### Droplet & SSH
- Created new Droplet on DigitalOcean
- Generated and added new SSH key
- Connected via SSH from local machine

### Docker & Firewall
- Installed Docker, Docker Compose, and Caddy
- Opened ports 22, 80, 443 in UFW firewall

### Project Upload
- Uploaded AstroBot (UI) and astrologyAnylizer (backend) via scp
- Cleaned up old/incorrect uploads

### Docker Compose
- Built and ran both backend and web containers
- Switched to Caddy for static web serving (port 80/443 conflict fix)
- Only backend container now runs via Docker

### DNS & Domain
- Set A records for @ and www to 164.92.192.21 in Cloudflare
- Set Proxy status to DNS only (gray cloud) for SSL setup
- Waited for DNS propagation

### Caddy & HTTPS
- Installed Caddy
- Copied Caddyfile for astreya.space and www.astreya.space
- Built Flutter web and copied to /srv for Caddy
- Restarted Caddy, confirmed SSL certificates issued

### Debugging
- Fixed port conflicts (Caddy vs Docker)
- Ensured backend container is running for API
- Confirmed DNS and firewall settings

## Outstanding
- Only backend should run in Docker; Caddy serves UI
- If planet descriptions are missing, check backend logs and API responses
- Next session: continue debugging API/data issues if needed

---

Let me know when you’re ready to continue, and I’ll pick up exactly where we left off!

## Caddy Troubleshooting (2026-05-30)

### Problem 1: `/api/*` returned `index.html` instead of JSON
**Symptom:** Frontend got `SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON`.

**Cause:** In the original Caddyfile, `root` / `file_server` / `try_files` were at the site level, so they matched `/api/*` requests before the proxy ever ran. The `handle_path` block was effectively unreachable.

**Fix:** Place `handle_path /api/*` first and wrap static serving in its own `handle` block:

```caddy
astreya.space, www.astreya.space {
    encode gzip

    handle_path /api/* {
        reverse_proxy localhost:8082
    }

    handle {
        root * /srv
        try_files {path} /index.html
        file_server
    }
}
```

### Problem 2: `502 Bad Gateway` after proxy was reachable
**Symptom:** `/api/chart` returned 502.

**Cause:** Caddy runs on the host (systemd), not inside Docker Compose, so the hostname `backend` does not resolve. Compose exposes the backend on the host via `ports: ["8082:8082"]`.

**Fix:** Proxy to `localhost:8082` instead of `backend:8082`:

```caddy
handle_path /api/* {
    reverse_proxy localhost:8082
}
```

### Problem 3: Missing query parameters in backend (`MissingServletRequestParameterException`)
**Symptom:** Spring backend logged `Required request parameter 'month' ... is not present`.

**Cause:** Earlier Caddyfile used `@api path /api/*` + `uri strip_prefix /api` + `reverse_proxy`, which in some configurations did not forward query strings reliably.

**Fix:** Use `handle_path /api/*` — it strips the `/api` prefix and forwards path + query string cleanly to the upstream.

### Deploy workflow for Caddyfile changes
From Windows:
```powershell
scp -i "C:\Users\zibit\.ssh\id_ed25519_do" C:\dev\AstroBot\deploy\Caddyfile root@164.92.192.21:/etc/caddy/Caddyfile
```
On the droplet:
```bash
systemctl restart caddy
systemctl status caddy
```

### Quick verification
- `curl -i "https://astreya.space/api/chart?year=1990&month=1&day=1&hour=21&minute=0&city=Tashkent&language=Eng"` should return 200 + JSON.
- `docker compose -f /root/AstroBot/docker-compose.prod.yml logs -f backend` should show the request reaching the backend with all params.

### Lessons
- In Caddy v2, directive **order matters only inside `route`**; at the site level Caddy uses its own ordering, which is why static handlers can shadow `/api/*`. Wrapping static serving in `handle` (or `handle_path`) makes routing explicit and predictable.
- Always proxy to `localhost:<published-port>` when Caddy runs on the host and the upstream runs in Docker with a published port.
- Prefer `handle_path` over `uri strip_prefix` + matchers for simple API prefixes — fewer moving parts, query strings forwarded automatically.

## Backend Chart Timeout Fix (2026-05-30)

### Problem 4: `/chart` hung before sending headers
**Symptom:**
- `https://astreya.space/api/chart?...` connected successfully through Caddy/TLS but returned 0 bytes until the client timed out.
- Direct backend probes to `http://127.0.0.1:8082/chart?...` also timed out.
- Backend logs showed successful chart math followed by Claude-related read timeouts.

**Cause:**
- The backend computed the natal chart synchronously, then blocked the same request on multiple optional Claude calls:
    - main interpretation
    - planetary interpretations
    - pattern interpretations
    - aspect interpretations

**Fix:**
- Updated backend `NatalChartService` to prioritize the main natal interpretation only during `/chart`.
- Removed the extra AI interpretation maps from the critical request path so the chart can return promptly.
- Updated `ChatService` to send a shorter natal interpretation prompt with a smaller token budget and faster timeout profile.

### Local validation
- Fixed `docker-compose.prod.yml` backend build context from the stale typo path to the real repo location:

```yaml
backend:
    build:
        context: ../astrologyAnalyzer/astrologyAnylizer
```

- Local backend image built successfully as `astreya-backend:latest`.
- Local container `astreya-backend` started successfully on port `8082`.
- Local `/chart` response returned JSON successfully with:
    - populated `interpretation`
    - empty `planetaryInterpretations`
    - empty `patternInterpretations`
    - empty `aspectInterpretations`

### Droplet path note
- On the droplet, the existing backend repo was found at:

```bash
/root/astrologyAnylizer
```

- The updated `docker-compose.prod.yml` expects the backend build context relative to `/root/AstroBot` at:

```bash
/root/astrologyAnalyzer/astrologyAnylizer
```

- Fastest compatibility fix on the droplet:

```bash
mkdir -p /root/astrologyAnalyzer
ln -sfn /root/astrologyAnylizer /root/astrologyAnalyzer/astrologyAnylizer
ls -la /root/astrologyAnalyzer
```

- After creating that symlink, verify the updated backend code before rebuilding:

```bash
grep -n "resp.setPlanetaryInterpretations(java.util.Collections.emptyMap())" /root/astrologyAnylizer/src/main/java/com/example/astrologyanalyzer/service/NatalChartService.java
grep -n "return callClaude(prompt, 700, 15000);" /root/astrologyAnylizer/src/main/java/com/example/astrologyanalyzer/service/ChatService.java
```

### Next production step
Run on the droplet inside the AstroBot directory:

```bash
docker compose -f docker-compose.prod.yml build backend
docker compose -f docker-compose.prod.yml up -d backend
docker ps --filter name=astreya-backend
docker logs --tail 120 astreya-backend
curl -v --max-time 20 "http://127.0.0.1:8082/chart?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng"
```

## Final Production Shape (2026-05-30)

### Backend API split
- `/chart` now returns chart structure first and does not block on Claude.
- `/chart/interpretation` was added as a separate endpoint for the main AI natal reading.
- Frontend flow now is:
    - request `/api/chart`
    - then request `/api/chart/interpretation`
    - keep the loading video visible until General is ready
    - then open the result on the General tab first

### Backend source files involved
- `src/main/java/com/example/astrologyanalyzer/controller/AstrologyController.java`
- `src/main/java/com/example/astrologyanalyzer/service/NatalChartService.java`
- `src/main/java/com/example/astrologyanalyzer/service/ChatService.java`
- `src/main/java/com/example/astrologyanalyzer/service/GeocodingService.java`
- `src/main/java/com/example/astrologyanalyzer/dto/ChartInterpretationResponse.java`

### Frontend source files involved
- `lib/services/api_service.dart`
- `lib/screens/chart_page.dart`
- `lib/theme/astro_palette.dart`

### Frontend container note
- The rebuilt Flutter web image runs with nginx inside the container on port `8080`.
- It cannot be published directly to host port `80` because Caddy already owns `80/443`.
- The working production arrangement is:
    - backend container published on host `8082`
    - web container published on host `127.0.0.1:8080`
    - Caddy proxies public site traffic to `127.0.0.1:8080`

### Docker network note
- The nginx config inside the web image proxies `/api/` to `http://backend:8082/`.
- Because of that, the working manual runtime uses a shared Docker network and gives the backend container the alias `backend`.
- Example runtime pattern:

```bash
docker network create astreya-net || true

docker run -d \
    --name astreya-backend \
    --network astreya-net \
    --network-alias backend \
    --restart unless-stopped \
    -p 8082:8082 \
    astreya-backend:latest

docker run -d \
    --name astreya-web \
    --network astreya-net \
    --restart unless-stopped \
    -p 127.0.0.1:8080:8080 \
    astreya-web:latest
```

### Caddy final routing
- Old configuration served stale Flutter files from `/srv`, which is why the public site stayed on the old UI even after the new web container was healthy.
- Final working Caddyfile:

```caddy
astreya.space, www.astreya.space {
        encode gzip

        handle_path /api/* {
                reverse_proxy localhost:8082
        }

        handle {
                reverse_proxy 127.0.0.1:8080
        }
}
```

### Caddy deploy workflow
From Windows:

```powershell
scp -i "C:\Users\zibit\.ssh\id_ed25519_do" C:\dev\AstroBot\deploy\Caddyfile root@164.92.192.21:/etc/caddy/Caddyfile
```

On the droplet:

```bash
caddy fmt --overwrite /etc/caddy/Caddyfile
caddy validate --config /etc/caddy/Caddyfile
systemctl reload caddy
```

### Verification checklist
- Backend direct:

```bash
curl -sS --max-time 20 'http://127.0.0.1:8082/chart?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng' | head -c 300
echo
curl -sS --max-time 25 'http://127.0.0.1:8082/chart/interpretation?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng' | head -c 500
echo
```

- Public API:

```bash
curl -sS 'https://astreya.space/api/chart/interpretation?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng' | head -c 300
echo
```

- Public frontend bundle contains the new split flow:

```bash
curl -sS https://astreya.space/main.dart.js | grep -o 'chart/interpretation' | head
echo
```

### Current remaining product note
- Hebrew still may feel incomplete compared with English because the AI interpretation returns, but some of the non-General surfaces are still driven by the original `/chart` payload and existing local UI formatting rules.
- The critical production fix is complete: General is now fetched separately and no longer blocks the whole chart screen.
