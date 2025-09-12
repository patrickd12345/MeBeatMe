// Test Strava authentication flow
import { test, expect } from '@playwright/test';

test.describe('Strava Authentication Test', () => {
  test('should test Strava authentication flow', async ({ page }) => {
    console.log('🔍 Testing Strava authentication flow...');
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait for data to load
    await page.waitForTimeout(2000);
    
    // Click Strava import button
    const stravaButton = page.locator('button:has-text("Import from Strava")');
    await expect(stravaButton).toBeVisible();
    await stravaButton.click();
    
    // Wait for modal
    const stravaModal = page.locator('#stravaModal');
    await expect(stravaModal).toBeVisible();
    
    console.log('✅ Strava modal opened');
    
    // Check if we're in the auth section
    const authSection = page.locator('#stravaAuthSection');
    const importSection = page.locator('#stravaImportSection');
    
    const authVisible = await authSection.isVisible();
    const importVisible = await importSection.isVisible();
    
    console.log('Auth section visible:', authVisible);
    console.log('Import section visible:', importVisible);
    
    if (authVisible) {
      console.log('✅ User needs to authenticate first');
      
      // Check if connect button exists
      const connectButton = page.locator('button:has-text("Connect to Strava")');
      if (await connectButton.isVisible()) {
        console.log('✅ Connect to Strava button found');
        
        // Click connect button
        await connectButton.click();
        
        // Wait for popup to open
        await page.waitForTimeout(2000);
        
        // Check if popup opened
        const pages = page.context().pages();
        console.log('Number of pages:', pages.length);
        
        if (pages.length > 1) {
          console.log('✅ Strava popup opened');
          
          // Get the popup page
          const popup = pages[pages.length - 1];
          
          // Wait for popup to load
          await popup.waitForLoadState('networkidle');
          
          const popupUrl = popup.url();
          console.log('Popup URL:', popupUrl);
          
          if (popupUrl.includes('strava.com')) {
            console.log('✅ Redirected to Strava for authentication');
            
            // Check if we can see the Strava auth page
            const stravaTitle = await popup.title();
            console.log('Strava page title:', stravaTitle);
            
            // Check if there's an authorize button
            const authorizeButton = popup.locator('button:has-text("Authorize"), input[type="submit"]');
            if (await authorizeButton.isVisible()) {
              console.log('✅ Strava authorize button found');
            } else {
              console.log('❌ Strava authorize button not found');
            }
          } else {
            console.log('❌ Not redirected to Strava');
          }
        } else {
          console.log('❌ Popup did not open');
        }
      } else {
        console.log('❌ Connect to Strava button not found');
      }
    } else if (importVisible) {
      console.log('✅ User is already authenticated, import form is visible');
      
      // Check import form elements
      const activityCount = page.locator('#activityCount');
      const activityType = page.locator('#activityType');
      const dateRange = page.locator('#dateRange');
      
      if (await activityCount.isVisible()) {
        console.log('✅ Activity count selector found');
      }
      if (await activityType.isVisible()) {
        console.log('✅ Activity type selector found');
      }
      if (await dateRange.isVisible()) {
        console.log('✅ Date range selector found');
      }
    } else {
      console.log('❌ Neither auth nor import section is visible');
    }
  });
});
