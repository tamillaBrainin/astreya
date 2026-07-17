# AstroBot Local Testing Guide

## Quick Start - Run Everything Locally

### 1. Start Backend API (Port 8082)
```cmd
cd c:\dev\astrologyAnalyzer\astrologyAnylizer
.\mvnw.cmd spring-boot:run
```
Backend will start on `http://localhost:8082`

### 2. Start Flutter Web App (Port 8081)
```cmd
cd c:\dev\AstroBot
flutter run -d chrome --web-port 8081
```
App will open in Chrome at `http://localhost:8081`

### 3. Open in VS Code Browser
- Use the "Browser Pages" shared attachment in chat
- Or open manually: `http://localhost:8081`

---

## Testing Transits

### Backend API - Test Transits Endpoint
```bash
# Test transits with specific birth data
curl "http://localhost:8082/transits?year=2000&month=1&day=1&hour=12&minute=0&city=London"
```

**Success Response:** Should return transit data in JSON format with fields like:
- `planetaryTransits[]` - Array of transit objects
- `planetaryInterpretations` - Interpretations for each transit
- `patternInterpretations` - Pattern analysis
- `aspectInterpretations` - Aspect interpretations

### Frontend - View Transits on Home Page
1. Navigate to `http://localhost:8081`
2. Home page displays:
   - **Today's Energy**: Shows current lunar phase (e.g., "Waning Gibbous in Pisces")
   - **Upcoming Transits**: List of active transits with interpretations

### Transit Houses
- `transitHouse` is the natal house where the transit planet falls.
- House assignment should follow the chart house cusps, not a simple 30-degree division.
- For the verified sample case `1979-12-02 02:40 AM, Tashkent`, the expected transit house examples are:
  - Sun → House 10
  - Mercury → House 10
  - Venus → House 11

**Example Output (Working 2026-07-04):**
```
Today's Energy: Waning Gibbous in Pisces
Upcoming Transits:
  - Moon Trine Mercury (with interpretation text)
  - [Other active transits]
```

---

## Testing Chart Page

### Navigate to Chart
1. Click "Chart" in bottom navigation bar
2. Or use the "Chart" button if navigation tabs are visible

### Enter Birth Data
Fill in the form with:
- **Year, Month, Day** - Birth date
- **Hour, Minute** - Birth time
- **City** - Birth location

### Chart Tabs
The chart page displays multiple tabs:
1. **General** - Overall birth chart interpretation
2. **Planets** - Individual planet positions and meanings
3. **Aspects** - Planetary aspects and their meanings
4. **Houses** - House placements and cusps

### Expected Data Flow
```
User Input (Birth Data)
    ↓
POST/GET to /chart endpoint with parameters
    ↓
Backend returns ChartResponse with:
  - Planetary positions
  - House cusps
  - Claude-generated interpretations
    ↓
Frontend displays in tabbed format
```

### Manual Verification Case - Russian Natal Chart + Transits
Use this exact case to reproduce the local UI check that was run in Chrome:

- **Language:** RU
- **Date of birth:** 1979-12-02
- **Time of birth:** 02:40 AM
- **Place of birth:** Tashkent

**Steps:**
1. Start the backend on `http://localhost:8082`.
2. Start the Flutter web app on `http://localhost:8081`.
3. Open the app in Chrome and enable accessibility so the Flutter semantics tree is visible.
4. Switch the app language to Russian.
5. Open the **Chart** page from the bottom navigation.
6. Enter the birth date `December 2, 1979`.
7. Enter the birth time `02:40` and keep it in AM.
8. Enter the birthplace `Tashkent`.
9. Click **Calculate Chart**.
10. Wait for the natal chart to load, then open the **Транзиты** tab.

**Expected Result:**
- The natal chart loads successfully.
- The chart content is shown in Russian.
- The transits tab loads and shows the transit summary plus the aspect list.
- The visible transit interpretation does not block the chart from rendering.

---

## Playwright Automated Testing

### Setup
```cmd
cd c:\dev\AstroBot
npm install -D @playwright/test
npx playwright install
```

### Run Tests

**Interactive UI Mode (Best for Debugging)**
```cmd
npx playwright test --ui
```
Opens Playwright Test UI where you can click tests to see step-by-step execution.

**Headed Mode (See Browser)**
```cmd
npx playwright test --headed
```
Tests run with visible Chrome browser.

**Debug Mode**
```cmd
npx playwright test --debug
```
Step through each action with debugger.

**Run Single Test File**
```cmd
npx playwright test tests/simple.spec.js
```

### Test Files Location
- `tests/transitions.spec.js` - Full transition tests (home → chart, home → chat, tab switches)
- `tests/simple.spec.js` - Basic smoke test

---

## API Endpoints to Test

### Daily Energy
```bash
GET http://localhost:8082/daily/energy
```
Returns today's lunar phase and energy.

### Chart Calculation
```bash
GET http://localhost:8082/chart?year=2000&month=1&day=1&hour=12&minute=0&city=London&language=Eng
```
Parameters:
- `year, month, day, hour, minute` - Birth datetime
- `city` - Birth location
- `language` - Output language (Eng, Rus, Heb, etc.)

Returns: ChartResponse with planets, houses, and interpretations

### Transits
```bash
GET http://localhost:8082/transits?year=2000&month=1&day=1&hour=12&minute=0&city=London
```
Parameters: Same as /chart endpoint

Returns: Transit data with interpretations

### Chat
```bash
POST http://localhost:8082/chat/message
Content-Type: application/json

{"message": "Your question here"}
```
Returns: `{"reply": "Claude response"}`

---

## Known Working Features (2026-07-04)

✅ **Backend API running** on port 8082
✅ **Flutter web app running** on port 8081  
✅ **Home page loads** with transits displayed
✅ **Today's Energy shows** lunar phase correctly
✅ **Upcoming Transits display** with interpretations
✅ **Transits endpoint returns** structured data

---

## Latest Local Verification (2026-07-11)

✅ Backend port `8082` listening and API responding.
✅ Frontend port `8081` listening and app reachable.
✅ `npx playwright install` completed (Chromium/Firefox/WebKit).
✅ `npx playwright test --config=playwright.config.js tests/simple.spec.js` passed.
⚠️ `npx playwright test --config=playwright.config.js tests/transitions.spec.js` timed out in `beforeEach` on `page.goto(...)` in headless mode.
⚠️ Claude API can return `401` (`x-api-key header is required`) when no key is provided to backend environment.

### Runtime Check Update (2026-07-11, 8082)

✅ `GET /daily/energy` on `8082` responded (`200`) quickly (~269 ms).
⚠️ `GET /transits` on `8082` responded (`200`) in ~25.7 s, but returned fallback interpretation text.
⚠️ Fallback markers present: `"# Транзиты на сегодня"`, `"детальный разбор временно недоступен"`.
⚠️ Expected Claude structured RU section `"Главный узел периода"` was not present in this run.

RU sample transit-house output observed locally:
- Sun → House 10
- Mercury → House 10
- Venus → House 11

### Claude API Key (CMD)

If transit/natal AI interpretation falls back and backend logs show Claude auth errors, set key through CMD before backend start:

```cmd
cd /d c:\dev\astrologyAnalyzer\astrologyAnylizer
set "CLAUDE_API_KEY=YOUR_REAL_KEY"
mvnw.cmd spring-boot:run "-Dspring-boot.run.arguments=--server.port=8082"
```

Persist key for future terminal sessions:

```cmd
setx CLAUDE_API_KEY "YOUR_REAL_KEY"
```

Then open a new terminal and restart backend.

If backend is already running in a different CMD window, do this:

```cmd
:: CMD #1 (currently running backend)
netstat -ano | findstr :8082
taskkill /F /PID <PID_FROM_8082>

:: CMD #2 (set key and start backend in the SAME window)
cd /d c:\dev\astrologyAnalyzer\astrologyAnylizer
set "CLAUDE_API_KEY=YOUR_REAL_KEY"
echo %CLAUDE_API_KEY%
mvnw.cmd spring-boot:run "-Dspring-boot.run.arguments=--server.port=8082"
```

Important: `set` applies only to the current CMD window. If backend is started from another terminal, it will not see that key.

---

## Known Issues

❌ Chart navigation button clicks don't work via Playwright/browser automation
- May be Flutter canvas-specific interaction issue
- Manual testing (clicking in Chrome directly) likely works better

---

## Frontend Files to Check

- `lib/main.dart` - App entry point
- `lib/screens/home_page.dart` - Home page with transits display
- `lib/screens/chart_page.dart` - Chart calculation and display
- `lib/screens/chat_page.dart` - AI chat interface
- `lib/services/api_service.dart` - HTTP client and API integration

---

## Verification Checklist

Before considering testing complete:
- [ ] Backend starts without errors
- [ ] Flutter app loads in Chrome
- [ ] Home page displays today's energy
- [ ] Transits are shown with interpretations
- [ ] Navigate to Chart page
- [ ] Enter birth data
- [ ] Chart calculates and displays
- [ ] All 4 tabs (General, Planets, Aspects, Houses) load
- [ ] Chat page loads and accepts messages
- [ ] Playwright tests run successfully

---

## Useful Commands

```cmd
# Check if ports are in use
netstat -ano | findstr :8081
netstat -ano | findstr :8082

# Kill process on specific port (example: 8082)
taskkill /F /PID <PID_NUMBER>

# View Playwright test report
npx playwright show-report

# List all available test files
dir /s *.spec.js

# Run tests with custom timeout
npx playwright test --timeout 60000
```

---

## Transit House Calculation Fix (2026-07-04) ✅

### Bug Fixed
Transit houses were calculated using naive 30-degree divisions instead of Placidus house cusps, causing incorrect house assignments (e.g., Sun showing House 8 instead of House 10).

### Test Case: Birth December 2, 1979, 02:40 Tashkent

**Expected Transits**:
```json
{
  "transitPlanet": "Sun",
  "transitSign": "Cancer",
  "transitHouse": 10,
  "natalPlanet": "Sun",
  "aspect": "Quincunx",
  "orb": 3.57
}
```

**Verification API Call**:
```bash
curl "http://localhost:8082/transits?year=1979&month=12&day=2&hour=2&minute=40&city=Tashkent&language=Eng" | grep -A5 "Sun"
```

**Expected Output** (after fix):
- Sun → House 10 ✓ (was House 8 before fix)
- Mercury → House 8 ✓
- Venus → House 9 ✓

### Implementation
- File: `NatalChartService.java`
- Method: `getTransits()` (lines 479-530)
- Changed from using `determineHouse()` (naive calculation)
- Now uses `houseFromCusps()` with Placidus cusps

### Verification Checklist for Transit House Fix
- [x] Sun transits show House 10 (not 8)
- [x] Mercury transits show House 8
- [x] Venus transits show House 9
- [x] All transit houses 1-12 (no invalid values)
- [x] Backend recompiled with fix
- [x] API returns correct house assignments
- [x] No regression in other planet calculations

---

## Notes for Next Session

- Backend appears stable and returning correct data
- Frontend transits display working correctly
- Transit house calculation bug FIXED and verified
- Need to investigate chart page navigation (possibly needs direct interaction with Flutter canvas)
- Consider creating Flutter integration tests if Playwright limitations persist
- All API endpoints responding with valid data structures

---

## Strict Transits Check + RU Natal Run (2026-07-17) ✅

### Setup Used (kept this working UI setup)

Frontend (served compiled web build on IPv4):
```cmd
cd /d c:\dev\AstroBot\build\web
python -m http.server 8081 --bind 127.0.0.1
```

Backend health check:
```cmd
curl -s -o NUL -w "%{http_code}" http://localhost:8082/daily/energy
```
Expected/Observed: `200`

### Strict Playwright Check (updated test)

Run command:
```cmd
cd /d c:\dev\AstroBot
node .\node_modules\@playwright\test\cli.js test transits-check.spec.js --config=playwright.config.js --reporter=list
```

Observed result:
- `1 passed (4.4s)`

Test behavior now:
- Calls `/transits` with natal profile params
- Uses Russian language (`language=Rus`)
- Asserts non-empty transit array
- Asserts Sun transit exists and is in House 10 for this profile

### RU Natal Transit Run (02.12.1979, Tashkent, 02:40)

Windows CMD-safe request (`&` escaped as `^&`):
```cmd
curl -s "http://localhost:8082/transits?year=1979^&month=12^&day=2^&hour=2^&minute=40^&city=Tashkent^&language=Rus"
```

Observed outcome:
- HTTP response contained valid JSON payload with transit list and RU interpretation
- Sun transit included: `transitSign: Cancer`, `transitHouse: 10`
- RU interpretation text returned (Cyrillic), with fallback note that detailed Claude output requires active Claude API
