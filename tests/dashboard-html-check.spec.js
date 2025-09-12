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
    
    // Check if the page contains "Bucket:" (old code)
    const hasBucket = content.includes('Bucket:');
    console.log('Page contains "Bucket:":', hasBucket);
    
    // Check if the page contains the latest code (no bucket references)
    const hasLatestCode = !content.includes('Bucket:');
    console.log('Page has latest code (no bucket):', hasLatestCode);
    
    // Check for specific elements that should be in the latest code
    const hasSessionsList = content.includes('id="sessions-list"');
    console.log('Page has sessions-list:', hasSessionsList);
    
    // The page should not contain bucket references
    expect(hasBucket).toBe(false);
    expect(hasSessionsList).toBe(true);
  });
});
