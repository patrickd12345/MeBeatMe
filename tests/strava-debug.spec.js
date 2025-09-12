// Test Strava import with debug logging
import { test, expect } from '@playwright/test';

test.describe('Strava Import Debug Test', () => {
  test('should test Strava import and show debug output', async ({ page }) => {
    console.log('=== STARTING STRAVA IMPORT DEBUG TEST ===');
    
    // Go to the production dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    console.log('✅ Dashboard loaded');
    
    // Check initial state
    const initialResponse = await page.request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const initialData = await initialResponse.json();
    console.log('Initial sessions count:', initialData.count);
    
    // Click Strava import button
    await page.click('button:has-text("🏃‍♂️ Import from Strava")');
    console.log('✅ Clicked Strava import button');
    
    // Wait for modal to appear
    await page.waitForSelector('#stravaModal', { state: 'visible' });
    console.log('✅ Strava modal opened');
    
    // Check if we can see the auth section
    const authSection = page.locator('#stravaAuthSection');
    const isAuthVisible = await authSection.isVisible();
    console.log('Auth section visible:', isAuthVisible);
    
    // Try to simulate a Strava import with a mock token
    console.log('=== TESTING STRAVA IMPORT API DIRECTLY ===');
    
    // Test with invalid token first
    const testResponse = await page.request.post('https://mebeatme.ready2race.run/api/strava/import', {
      data: {
        access_token: 'test_invalid_token',
        count: 5,
        type: 'Run',
        days: 30
      }
    });
    
    const testResult = await testResponse.json();
    console.log('Test import result:', testResult);
    
    // Check if we can see any error messages in the UI
    const errorElement = page.locator('#error');
    const errorText = await errorElement.textContent();
    console.log('Error message in UI:', errorText);
    
    // Check final state
    const finalResponse = await page.request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const finalData = await finalResponse.json();
    console.log('Final sessions count:', finalData.count);
    
    console.log('=== STRAVA IMPORT DEBUG TEST COMPLETE ===');
  });
  
  test('should test Strava token exchange', async ({ page }) => {
    console.log('=== TESTING STRAVA TOKEN EXCHANGE ===');
    
    // Test token exchange endpoint
    const tokenResponse = await page.request.post('https://mebeatme.ready2race.run/api/strava/token', {
      data: {
        code: 'test_code'
      }
    });
    
    const tokenResult = await tokenResponse.json();
    console.log('Token exchange result:', tokenResult);
    
    console.log('=== TOKEN EXCHANGE TEST COMPLETE ===');
  });
});


