# Backend Deployment Notes

## Service
- Repo: `c:\dev\astrologyAnalyzer\astrologyAnylizer`
- App: Spring Boot backend for AstroBot chart, transit, and chat endpoints
- Local container name: `astreya-backend`
- Local image: `astreya-backend:latest`
- HTTP port: `8082`

## Chart Endpoint Fix (2026-05-30)

### Problem
- `/chart` could hang for 20+ seconds and return no body.
- Core chart math completed, but the request waited on multiple Claude interpretation calls before writing the response.
- Production logs showed repeated `Claude Chat API Status: 200` followed by `Interpretation error: Read timed out` and `Aspect interpretations error: Read timed out`.

### Root Cause
- `NatalChartService` built the natal chart synchronously, then blocked the same HTTP request on several optional AI enrichments:
  - general interpretation
  - planetary interpretations
  - pattern interpretations
  - aspect interpretations

### Fix Applied
- `NatalChartService` now prioritizes the main natal interpretation only for `/chart`.
- Decorative AI payloads were removed from the critical `/chart` request path and are returned as empty maps.
- `ChatService` was updated so the natal interpretation prompt is shorter and uses a smaller, faster Claude request budget.

## Files Changed
- `src/main/java/com/example/astrologyanalyzer/service/NatalChartService.java`
- `src/main/java/com/example/astrologyanalyzer/service/ChatService.java`

## Endpoint Split (2026-05-30 later)

### Why the first fix was not enough
- Even after trimming `/chart`, waiting for Claude inside the same HTTP response still made the General reading unreliable in production.
- The durable fix was to separate chart computation from AI interpretation.

### Final backend behavior
- `/chart` now returns chart structure only:
  - planets
  - houses
  - ascendant / mc
  - pars fortuna
  - patterns
  - aspects
- `/chart/interpretation` now generates and returns the main natal reading.
- If Claude does not answer, `NatalChartService` falls back to a deterministic local interpretation string instead of hanging the endpoint.

### Additional files changed for the split
- `src/main/java/com/example/astrologyanalyzer/controller/AstrologyController.java`
- `src/main/java/com/example/astrologyanalyzer/dto/ChartInterpretationResponse.java`

### Production validation target
- Direct backend interpretation probe should now return JSON instead of timing out or 404ing:

```bash
curl -sS --max-time 25 'http://127.0.0.1:8082/chart/interpretation?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng' | head -c 500
echo
```

## Compose Path Correction
- The AstroBot compose file originally pointed the backend build context at a stale typo path: `../astrologyAnylizer`.
- The working local build used the corrected backend context:

```yaml
backend:
  build:
    context: ../astrologyAnalyzer/astrologyAnylizer
```

## Droplet Path Reality
- The production droplet already had the backend repo at:

```bash
/root/astrologyAnylizer
```

- The corrected AstroBot compose file on the droplet expects the backend build context at:

```bash
/root/astrologyAnalyzer/astrologyAnylizer
```

- To reconcile those without re-uploading the whole backend immediately, create a compatibility symlink on the droplet:

```bash
mkdir -p /root/astrologyAnalyzer
ln -sfn /root/astrologyAnylizer /root/astrologyAnalyzer/astrologyAnylizer
ls -la /root/astrologyAnalyzer
```

- Before rebuilding production, verify the updated backend code is present in the existing droplet repo:

```bash
grep -n "resp.setPlanetaryInterpretations(java.util.Collections.emptyMap())" /root/astrologyAnylizer/src/main/java/com/example/astrologyanalyzer/service/NatalChartService.java
grep -n "return callClaude(prompt, 700, 15000);" /root/astrologyAnylizer/src/main/java/com/example/astrologyanalyzer/service/ChatService.java
```

## Validation
- Local compile succeeded:

```powershell
.\mvnw.cmd -q -DskipTests compile
```

- Local Docker image built successfully.
- Local backend container started successfully on port `8082`.
- Verified local `/chart` response now returns JSON with a populated `interpretation` field.
- Expected current payload shape:
  - `interpretation` is populated
  - `planetaryInterpretations` is empty
  - `patternInterpretations` is empty
  - `aspectInterpretations` is empty

## Verified Local Response Shape
- Core chart fields returned successfully:
  - `planets`
  - `houses`
  - `ascendant`
  - `mc`
  - `parsFortuna`
  - `patterns`
  - `aspects`
- Main natal reading returned successfully in `interpretation`.
- Example local result characteristics:
  - Capricorn-heavy 6th-house chart returned immediately
  - `interpretation` contained a full four-paragraph natal reading
  - optional AI detail maps were intentionally empty

## Known Minor Issue
- Some generated pattern labels still show mojibake for Unicode aspect symbols, for example `â¹` or `â`.
- This is an encoding/display issue only and does not affect chart computation or the main natal interpretation.

## Local Rebuild

Run from `c:\dev\AstroBot`:

```powershell
docker compose -f docker-compose.prod.yml build backend
docker compose -f docker-compose.prod.yml up -d backend
docker ps --filter name=astreya-backend
docker logs --tail 120 astreya-backend
```

## Production Rebuild

Run on the droplet in the AstroBot directory:

```bash
docker compose -f docker-compose.prod.yml build backend
docker compose -f docker-compose.prod.yml up -d backend
docker ps --filter name=astreya-backend
docker logs --tail 120 astreya-backend
curl -v --max-time 20 "http://127.0.0.1:8082/chart?year=1990&month=1&day=14&hour=17&minute=15&city=Tel%20Aviv&language=Eng"
```

## Direct Backend Build Fallback

If compose path or stale-image issues make the backend rebuild ambiguous, build directly from the backend repo on the droplet:

```bash
cd /root/astrologyAnylizer
docker build --no-cache -t astreya-backend:latest .
docker rm -f astreya-backend || true
docker run -d --name astreya-backend --restart unless-stopped -p 8082:8082 astreya-backend:latest
```

This bypasses compose build-context confusion and is useful when verifying that the jar really includes the new controller/service changes.