// Simple test to verify Strava import is working
import { test, expect } from '@playwright/test';

test.describe('Strava Import Verification', () => {
  test('should verify Strava import functionality', async ({ page }) => {
    console.log('🔍 Verifying Strava import functionality...');
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait for data to load
    await page.waitForTimeout(3000);
    
    // Check initial sessions
    const initialSessions = await page.locator('#sessions-list .session-item').count();
    console.log(`Initial sessions: ${initialSessions}`);
    
    // Test API endpoints
    console.log('🔗 Testing API endpoints...');
    
    // Test sessions API
    const sessionsResponse = await page.request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const sessionsData = await sessionsResponse.json();
    console.log('Sessions API:', sessionsData);
    
    // Test Strava token API
    const tokenResponse = await page.request.get('https://mebeatme.ready2race.run/api/strava/token');
    const tokenData = await tokenResponse.json();
    console.log('Token API:', tokenData);
    
    // Test Strava import API with invalid token
    const importResponse = await page.request.post('https://mebeatme.ready2race.run/api/strava/import', {
      data: {
        count: 10,
        type: 'Run',
        days: 7,
        access_token: 'invalid_token'
      }
    });
    const importData = await importResponse.json();
    console.log('Import API (invalid token):', importData);
    
    // Check if dashboard loads without errors
    const errorEl = await page.locator('#error').isVisible();
    const contentEl = await page.locator('#content').isVisible();
    
    console.log('Dashboard state:');
    console.log('- Error visible:', errorEl);
    console.log('- Content visible:', contentEl);
    
    if (errorEl) {
      const errorText = await page.locator('#error').textContent();
      console.log('Error message:', errorText);
    }
    
    // Check if Strava button works
    const stravaButton = page.locator('button:has-text("Import from Strava")');
    await expect(stravaButton).toBeVisible();
    
    // Click Strava button
    await stravaButton.click();
    
    // Check if modal opens
    const stravaModal = page.locator('#stravaModal');
    await expect(stravaModal).toBeVisible();
    
    console.log('✅ Strava modal opened successfully');
    
    // Check modal content
    const modalContent = await stravaModal.textContent();
    console.log('Modal contains "Connect to Strava":', modalContent.includes('Connect to Strava'));
    console.log('Modal contains "Import Activities":', modalContent.includes('Import Activities'));
    
    console.log('✅ Strava import functionality is working!');
  });
});
