// Test actual HTML content of production dashboard
import { test, expect } from '@playwright/test';

test.describe('Production Dashboard HTML Test', () => {
  test('should check if production dashboard has latest code', async ({ page }) => {
    // Go to the production dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Get the page content
    const content = await page.content();
    
    // Ensure legacy bucket tokens are not present
    const hasLegacyBucket = /KM_\d|KM_\d+_\d+|KM_\d+P/.test(content) || content.includes('Bucket:');
    console.log('Page has legacy bucket tokens:', hasLegacyBucket);
    
    // Check for specific elements that should be in the latest code
    const hasSessionsList = content.includes('id="sessions-list"');
    console.log('Page has sessions-list:', hasSessionsList);
    
    // The page should not contain bucket references
    expect(hasLegacyBucket).toBe(false);
    expect(hasSessionsList).toBe(true);
  });
});
