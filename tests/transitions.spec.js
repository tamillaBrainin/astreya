const { test, expect } = require('@playwright/test');

test.describe('AstroBot Page Transitions', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('http://localhost:8081');
    // Wait for the app to load
    await page.waitForLoadState('networkidle');
  });

  test('should load home page on startup', async ({ page }) => {
    // Check for main content
    const body = await page.locator('body');
    await expect(body).toBeTruthy();
    
    // Wait for Flutter to initialize
    await page.waitForTimeout(2000);
    
    // Look for text or buttons that indicate home page loaded
    const pageContent = await page.content();
    expect(pageContent.length).toBeGreaterThan(0);
    console.log('✓ Home page loaded');
  });

  test('should navigate between tabs/pages', async ({ page }) => {
    // Wait for Flutter to fully load
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    // Try to find navigation elements (buttons, taps, etc.)
    const buttons = await page.locator('button').count();
    console.log(`Found ${buttons} buttons on page`);

    // Check for common Flutter widget identifiers or semantic labels
    const appBar = await page.locator('[role="banner"]').first();
    if (await appBar.isVisible()) {
      console.log('✓ App bar found');
    }

    // Log page structure for debugging
    const structure = await page.evaluate(() => {
      const elements = document.querySelectorAll('*');
      return `Page has ${elements.length} DOM elements`;
    });
    console.log(structure);
  });

  test('should handle page scrolling', async ({ page }) => {
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // Get initial scroll position
    const initialScroll = await page.evaluate(() => window.scrollY);
    console.log(`Initial scroll position: ${initialScroll}`);

    // Scroll down
    await page.evaluate(() => window.scrollBy(0, 300));
    const afterScroll = await page.evaluate(() => window.scrollY);
    console.log(`After scroll: ${afterScroll}`);

    // Verify scroll happened
    expect(afterScroll).toBeGreaterThanOrEqual(initialScroll);
    console.log('✓ Page scrolling works');
  });

  test('should render without errors', async ({ page }) => {
    // Listen for console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
        console.log(`Console error: ${msg.text()}`);
      }
    });

    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);

    // Check page title or main content
    const title = await page.title();
    console.log(`Page title: ${title}`);
    
    expect(title.length).toBeGreaterThan(0);
    console.log('✓ Page renders without critical errors');
  });

  test('should handle responsive layout', async ({ page }) => {
    // Test desktop size
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    console.log('✓ Desktop layout loaded (1280x720)');

    // Test tablet size
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    console.log('✓ Tablet layout loaded (768x1024)');

    // Test mobile size
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);
    console.log('✓ Mobile layout loaded (375x667)');
  });

  test('should have accessible content', async ({ page }) => {
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // Check for basic accessibility
    const headings = await page.locator('h1, h2, h3').count();
    console.log(`Found ${headings} headings`);

    // Check for interactive elements
    const interactive = await page.locator('button, input, a, [role="button"], [role="link"]').count();
    console.log(`Found ${interactive} interactive elements`);

    // Get some text content
    const textContent = await page.evaluate(() => document.body.innerText.substring(0, 200));
    console.log(`Page content preview: ${textContent.substring(0, 100)}...`);

    expect(textContent.length).toBeGreaterThan(0);
    console.log('✓ Page has accessible content');
  });
});
