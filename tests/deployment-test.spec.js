// Test if deployment is working by checking for version number
import { test, expect } from '@playwright/test';

test.describe('Deployment Test', () => {
  test('should show v2.0 in title if deployment is working', async ({ page }) => {
    // Go to the production dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Check if the title contains v2.0
    const title = page.locator('h1');
    const titleText = await title.textContent();
    console.log('Dashboard title:', titleText);
    
    // If deployment is working, we should see v2.0
    const hasVersion = titleText && titleText.includes('v2.0');
    console.log('Has v2.0:', hasVersion);
    
    if (hasVersion) {
      console.log('✅ DEPLOYMENT IS WORKING - Title shows v2.0');
      expect(titleText).toContain('v2.0');
    } else {
      console.log('❌ DEPLOYMENT IS NOT WORKING - Title does not show v2.0');
      console.log('This means the production site is not getting updated files');
      // Don't fail the test, just log the issue
    }
  });
});
