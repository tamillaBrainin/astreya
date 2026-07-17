const { test, expect } = require('@playwright/test');

test('Check Transits Display in AstroBot App', async ({ page }) => {
  test.setTimeout(60000);
  console.log('Starting strict transits check (RU natal profile)');

  await page.goto('http://127.0.0.1:8081', { waitUntil: 'domcontentloaded' });

  const params = new URLSearchParams({
    year: '1979',
    month: '12',
    day: '2',
    hour: '2',
    minute: '40',
    city: 'Tashkent',
    language: 'Rus',
  });

  const apiUrl = `http://localhost:8082/transits?${params.toString()}`;
  const apiResponse = await page.request.get(apiUrl);
  expect(apiResponse.status(), 'Expected /transits RU natal request to succeed').toBe(200);

  const payload = await apiResponse.json();
  expect(Array.isArray(payload.transits), 'Expected payload.transits to be an array').toBeTruthy();
  expect(payload.transits.length, 'Expected at least one active transit').toBeGreaterThan(0);

  const sunTransit = payload.transits.find((item) => item.transitPlanet === 'Sun');
  expect(sunTransit, 'Expected at least one Sun transit for this profile').toBeTruthy();
  expect(typeof sunTransit.transitSign, 'Missing transitSign on Sun transit').toBe('string');
  expect(typeof sunTransit.transitHouse, 'Missing transitHouse on Sun transit').toBe('number');
  expect(sunTransit.transitHouse, 'Expected Sun transit house to be 10 for this profile').toBe(10);

  expect(typeof payload.interpretation, 'Expected interpretation text').toBe('string');
  expect(payload.interpretation.length, 'Expected non-empty interpretation').toBeGreaterThan(0);

  await page.screenshot({ path: 'transits-test.png' });
});
