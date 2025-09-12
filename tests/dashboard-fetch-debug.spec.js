// Test the exact same fetch that dashboard is doing
import { test, expect } from '@playwright/test';

test.describe('Dashboard Fetch Debug', () => {
  test('should test dashboard fetch calls', async ({ page }) => {
    console.log('🔍 Testing dashboard fetch calls...');
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    
    // Inject test code to test the exact same fetch calls
    const result = await page.evaluate(async () => {
      const results = {};
      
      try {
        console.log('Testing bests API...');
        const bestsResponse = await fetch('/api/sync/bests');
        const bestsData = await bestsResponse.json();
        results.bests = { success: true, data: bestsData };
      } catch (error) {
        results.bests = { success: false, error: error.message };
      }
      
      try {
        console.log('Testing sessions API...');
        const sessionsResponse = await fetch('/api/sync/sessions');
        const sessionsData = await sessionsResponse.json();
        results.sessions = { success: true, data: sessionsData };
      } catch (error) {
        results.sessions = { success: false, error: error.message };
      }
      
      return results;
    });
    
    console.log('Fetch results:', result);
    
    // Check if both APIs work
    expect(result.bests.success).toBe(true);
    expect(result.sessions.success).toBe(true);
    
    console.log('✅ Both APIs work from dashboard context!');
  });
});
