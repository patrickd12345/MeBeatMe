// Comprehensive Strava import test
import { test, expect } from '@playwright/test';

test.describe('Strava Import Debug', () => {
  test('should debug Strava import process', async ({ page }) => {
    console.log('🔍 Starting comprehensive Strava import debug...');
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Check initial state
    console.log('📊 Checking initial dashboard state...');
    const initialSessions = await page.locator('#sessions-list .session-item').count();
    console.log(`Initial sessions count: ${initialSessions}`);
    
    // Check if there are any error messages
    const errorMessages = await page.locator('.error, [class*="error"]').allTextContents();
    if (errorMessages.length > 0) {
      console.log('❌ Error messages found:', errorMessages);
    }
    
    // Check API endpoints
    console.log('🔗 Testing API endpoints...');
    
    // Test sessions API
    const sessionsResponse = await page.request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const sessionsData = await sessionsResponse.json();
    console.log('Sessions API response:', sessionsData);
    
    // Test bests API
    const bestsResponse = await page.request.get('https://mebeatme.ready2race.run/api/sync/bests');
    const bestsData = await bestsResponse.json();
    console.log('Bests API response:', bestsData);
    
    // Test Strava token API
    const tokenResponse = await page.request.get('https://mebeatme.ready2race.run/api/strava/token');
    const tokenData = await tokenResponse.json();
    console.log('Strava token API response:', tokenData);
    
    // Check if Strava button exists and is clickable
    console.log('🏃‍♂️ Testing Strava import button...');
    const stravaButton = page.locator('button:has-text("Import from Strava")');
    await expect(stravaButton).toBeVisible();
    
    // Click Strava button
    await stravaButton.click();
    
    // Wait for modal
    const modal = page.locator('.modal, [class*="modal"]');
    await expect(modal).toBeVisible();
    
    console.log('✅ Strava modal opened successfully');
    
    // Check if there's a connect button
    const connectButton = page.locator('button:has-text("Connect to Strava"), button:has-text("Connect")');
    if (await connectButton.isVisible()) {
      console.log('🔗 Connect to Strava button found');
    }
    
    // Check if there's an import button
    const importButton = page.locator('button:has-text("Import"), button:has-text("Import Activities")');
    if (await importButton.isVisible()) {
      console.log('📥 Import button found');
    }
    
    // Check for any existing token or authentication status
    const tokenInput = page.locator('input[type="text"], input[placeholder*="token"], input[name*="token"]');
    if (await tokenInput.isVisible()) {
      console.log('🔑 Token input field found');
    }
    
    // Check dashboard content for any session data
    console.log('📋 Checking dashboard content...');
    const dashboardContent = await page.textContent('body');
    
    // Look for any session-related content
    if (dashboardContent.includes('session')) {
      console.log('✅ Found session-related content in dashboard');
    }
    
    if (dashboardContent.includes('KM_')) {
      console.log('⚠️ Found KM_ references (bucket data) in dashboard');
    }
    
    if (dashboardContent.includes('Error')) {
      console.log('❌ Found error messages in dashboard');
    }
    
    // Check console logs
    console.log('📝 Checking browser console...');
    const consoleLogs = [];
    page.on('console', msg => {
      consoleLogs.push(`${msg.type()}: ${msg.text()}`);
    });
    
    // Wait a bit to collect console logs
    await page.waitForTimeout(2000);
    
    if (consoleLogs.length > 0) {
      console.log('Console logs:', consoleLogs);
    }
    
    console.log('🎯 Debug complete!');
  });
});
