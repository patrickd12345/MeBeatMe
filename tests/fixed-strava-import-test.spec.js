// Test the fixed Strava import flow
import { test, expect } from '@playwright/test';

test.describe('Fixed Strava Import Test', () => {
  test('should test the complete fixed Strava import flow', async ({ page }) => {
    console.log('🔍 Testing fixed Strava import flow...');
    
    // Collect console logs
    const consoleLogs = [];
    page.on('console', msg => {
      consoleLogs.push(`[${msg.type()}] ${msg.text()}`);
    });
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait for data to load
    await page.waitForTimeout(3000);
    
    // Check initial state
    const initialSessions = await page.locator('#sessions-list .session-item').count();
    console.log(`Initial sessions count: ${initialSessions}`);
    
    // Click Strava import button
    const stravaButton = page.locator('button:has-text("Import from Strava")');
    await expect(stravaButton).toBeVisible();
    await stravaButton.click();
    
    // Wait for modal
    const stravaModal = page.locator('#stravaModal');
    await expect(stravaModal).toBeVisible();
    
    console.log('✅ Strava modal opened');
    
    // Check if we're in auth section
    const authSection = page.locator('#stravaAuthSection');
    const authVisible = await authSection.isVisible();
    
    if (authVisible) {
      console.log('✅ User needs to authenticate');
      
      // Click connect button
      const connectButton = page.locator('button:has-text("Connect to Strava")');
      await expect(connectButton).toBeVisible();
      await connectButton.click();
      
      console.log('✅ Connect button clicked');
      
      // Wait for popup
      await page.waitForTimeout(2000);
      
      // Check if popup opened
      const pages = page.context().pages();
      console.log('Number of pages:', pages.length);
      
      if (pages.length > 1) {
        console.log('✅ Strava popup opened');
        
        const popup = pages[pages.length - 1];
        await popup.waitForLoadState('networkidle');
        
        const popupUrl = popup.url();
        console.log('Popup URL:', popupUrl);
        
        if (popupUrl.includes('strava.com')) {
          console.log('✅ Redirected to Strava');
          
          // Check for authorize button
          const authorizeButton = popup.locator('button:has-text("Authorize"), input[type="submit"]');
          if (await authorizeButton.isVisible()) {
            console.log('✅ Strava authorize button found');
            
            // Click authorize (this will complete the OAuth flow)
            await authorizeButton.click();
            console.log('✅ Authorize button clicked');
            
            // Wait for callback
            await page.waitForTimeout(5000);
            
            // Check if we're back to the dashboard and import form is visible
            const importSection = page.locator('#stravaImportSection');
            const importVisible = await importSection.isVisible();
            
            if (importVisible) {
              console.log('✅ Authentication successful! Import form is visible');
              
              // Check import form elements
              const activityCount = page.locator('#activityCount');
              const activityType = page.locator('#activityType');
              const dateRange = page.locator('#dateRange');
              
              if (await activityCount.isVisible()) {
                console.log('✅ Activity count selector found');
                
                // Set import settings
                await activityCount.selectOption('10');
                await activityType.selectOption('Run');
                await dateRange.selectOption('7');
                
                console.log('✅ Import settings configured');
                
                // Click import button
                const importButton = page.locator('button:has-text("Import Activities")');
                await expect(importButton).toBeVisible();
                await importButton.click();
                
                console.log('✅ Import button clicked');
                
                // Wait for import to complete
                await page.waitForTimeout(10000);
                
                // Check for notifications
                const notifications = await page.locator('.notification, [class*="notification"]').allTextContents();
                if (notifications.length > 0) {
                  console.log('Notifications:', notifications);
                }
                
                // Check if sessions were added
                const finalSessions = await page.locator('#sessions-list .session-item').count();
                console.log(`Final sessions count: ${finalSessions}`);
                
                if (finalSessions > initialSessions) {
                  console.log('🎉 SUCCESS: New sessions were imported!');
                } else {
                  console.log('❌ No new sessions were imported');
                }
              }
            } else {
              console.log('❌ Import form not visible after authentication');
            }
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
      console.log('✅ User is already authenticated');
    }
    
    // Show console logs
    console.log('Console logs:');
    consoleLogs.forEach(log => console.log(log));
  });
});
