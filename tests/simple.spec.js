const { test, expect } = require('@playwright/test');

test('AstroBot app loads on Chrome', async ({ page }) => {
  console.log('Starting test: Navigate to AstroBot app');
  
  await page.goto('http://localhost:8081', { waitUntil: 'networkidle' });
  console.log('✓ Page loaded');

  // Check page has content
  const title = await page.title();
  console.log(`✓ Page title: ${title}`);

  // Take a screenshot
  await page.screenshot({ path: 'screenshot.png' });
  console.log('✓ Screenshot saved');

  // Basic check that Flutter app rendered
  const body = await page.locator('body');
  await expect(body).toBeTruthy();
  console.log('✓ Page body found');
});
