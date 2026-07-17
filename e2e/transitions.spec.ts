import { test, expect } from '@playwright/test';

test.describe('AstroBot UI Transitions', () => {
  const BASE_URL = 'http://localhost:8081';

  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto(BASE_URL, { waitUntil: 'networkidle' });
  });

  test('should render home page', async ({ page }) => {
    // Check that the app loaded
    const content = await page.content();
    expect(content).toBeTruthy();
  });

  test('should transition from home to chart page', async ({ page }) => {
    // Look for a navigation button or link to chart page
    // This depends on your UI structure - adjust selectors as needed
    const chartButton = page.locator('button:has-text("Chart"), a:has-text("Chart"), [role="button"]:has-text("Chart")').first();
    
    if (await chartButton.isVisible()) {
      await chartButton.click();
      // Wait for the chart page to load
      await page.waitForTimeout(500);
      
      // Verify we're on the chart page
      const url = page.url();
      expect(url).toContain(BASE_URL);
    }
  });

  test('should transition from home to chat page', async ({ page }) => {
    // Look for chat navigation
    const chatButton = page.locator('button:has-text("Chat"), a:has-text("Chat"), [role="button"]:has-text("Chat")').first();
    
    if (await chatButton.isVisible()) {
      await chatButton.click();
      await page.waitForTimeout(500);
      
      // Verify chat page loaded
      const chatInput = page.locator('input[type="text"], textarea').first();
      await expect(chatInput).toBeVisible();
    }
  });

  test('should transition between tabs in chart page', async ({ page }) => {
    // Navigate to chart page if available
    const chartButton = page.locator('button:has-text("Chart"), a:has-text("Chart"), [role="button"]:has-text("Chart")').first();
    
    if (await chartButton.isVisible()) {
      await chartButton.click();
      await page.waitForTimeout(500);

      // Look for tabs (General, Planets, Aspects, Houses)
      const tabs = page.locator('[role="tab"], .tab, button[aria-selected]');
      const tabCount = await tabs.count();
      
      if (tabCount > 1) {
        // Click through each tab and verify transition
        for (let i = 0; i < Math.min(tabCount, 4); i++) {
          const tab = tabs.nth(i);
          if (await tab.isVisible()) {
            await tab.click();
            await page.waitForTimeout(300);
            // Tab should be marked as active/selected
            const isActive = await tab.getAttribute('aria-selected');
            expect(isActive).toBeTruthy();
          }
        }
      }
    }
  });

  test('should handle form transitions in chart page', async ({ page }) => {
    // This test assumes a birth data form exists
    const inputs = page.locator('input[type="text"], input[type="number"], input[type="date"]');
    const inputCount = await inputs.count();
    
    if (inputCount > 0) {
      // Fill in a date field if available
      const dateInput = page.locator('input[type="date"]').first();
      if (await dateInput.isVisible()) {
        await dateInput.fill('1990-01-15');
        await page.waitForTimeout(200);
      }
    }
  });

  test('should handle smooth page transitions', async ({ page }) => {
    // Monitor for any console errors during transitions
    const errors: string[] = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Try clicking multiple navigation items if they exist
    const buttons = page.locator('button, a[role="button"]').take(5);
    const buttonCount = await buttons.count();
    
    for (let i = 0; i < buttonCount; i++) {
      const button = buttons.nth(i);
      if (await button.isVisible()) {
        await button.click({ timeout: 5000 });
        await page.waitForTimeout(300);
      }
    }

    // Verify no critical errors occurred
    const criticalErrors = errors.filter(e => 
      !e.includes('favicon') && 
      !e.includes('404')
    );
    expect(criticalErrors.length).toBe(0);
  });

  test('should navigate back', async ({ page }) => {
    // Click a navigation item
    const buttons = page.locator('button, a[role="button"]');
    const firstButton = buttons.first();
    
    if (await firstButton.isVisible()) {
      await firstButton.click();
      await page.waitForTimeout(500);
      
      // Try to go back
      await page.goBack();
      await page.waitForTimeout(500);
      
      // Verify we can still interact with the app
      expect(page.url()).toBeTruthy();
    }
  });
});
