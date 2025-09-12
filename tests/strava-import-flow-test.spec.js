// Test actual Strava import process
import { test, expect } from '@playwright/test';

test.describe('Strava Import Process Test', () => {
  test('should test complete Strava import flow', async ({ page }) => {
    console.log('🔍 Testing complete Strava import flow...');
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait for data to load
    await page.waitForTimeout(2000);
    
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
    
    // Check what's in the modal
    const modalContent = await stravaModal.textContent();
    console.log('Modal content:', modalContent);
    
    // Look for connect button
    const connectButton = page.locator('button:has-text("Connect to Strava")');
    if (await connectButton.isVisible()) {
      console.log('🔗 Connect to Strava button found');
      
      // Click connect button
      await connectButton.click();
      
      // Wait for redirect or new window
      await page.waitForTimeout(2000);
      
      // Check if we're redirected to Strava
      const currentUrl = page.url();
      console.log('Current URL after connect:', currentUrl);
      
      if (currentUrl.includes('strava.com')) {
        console.log('✅ Redirected to Strava for authentication');
      } else {
        console.log('❌ Not redirected to Strava');
      }
    } else {
      console.log('❌ Connect to Strava button not found');
    }
    
    // Look for import button
    const importButton = page.locator('button:has-text("Import"), button:has-text("Import Activities")');
    if (await importButton.isVisible()) {
      console.log('📥 Import button found');
      
      // Try clicking import button
      await importButton.click();
      await page.waitForTimeout(3000);
      
      // Check for any notifications or errors
      const notifications = await page.locator('.notification, [class*="notification"]').allTextContents();
      if (notifications.length > 0) {
        console.log('Notifications:', notifications);
      }
      
      // Check if sessions were added
      const finalSessions = await page.locator('#sessions-list .session-item').count();
      console.log(`Final sessions count: ${finalSessions}`);
      
      if (finalSessions > initialSessions) {
        console.log('✅ New sessions were added!');
      } else {
        console.log('❌ No new sessions were added');
      }
    } else {
      console.log('❌ Import button not found');
    }
    
    // Check console for any errors
    const consoleLogs = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleLogs.push(`ERROR: ${msg.text()}`);
      }
    });
    
    await page.waitForTimeout(2000);
    
    if (consoleLogs.length > 0) {
      console.log('Console errors:', consoleLogs);
    }
  });
});
