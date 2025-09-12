// Test the enhanced debugging
import { test, expect } from '@playwright/test';

test.describe('Enhanced Debugging Test', () => {
  test('should check enhanced debugging output', async ({ page }) => {
    console.log('🔍 Testing enhanced debugging...');
    
    // Collect console logs
    const consoleLogs = [];
    page.on('console', msg => {
      consoleLogs.push(`[${msg.type()}] ${msg.text()}`);
    });
    
    // Go to dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait for the setTimeout to trigger
    await page.waitForTimeout(2000);
    
    // Check the console logs
    console.log('Console logs:');
    consoleLogs.forEach(log => console.log(log));
    
    // Check dashboard state
    const errorEl = await page.locator('#error').isVisible();
    const contentEl = await page.locator('#content').isVisible();
    
    console.log('Dashboard state:');
    console.log('- Error visible:', errorEl);
    console.log('- Content visible:', contentEl);
    
    if (errorEl) {
      const errorText = await page.locator('#error').textContent();
      console.log('Error message:', errorText);
    }
    
    // Check if sessions are displayed
    const sessionItems = await page.locator('#sessions-list .session-item').count();
    console.log('Session items count:', sessionItems);
    
    if (sessionItems > 0) {
      console.log('✅ Sessions are displayed!');
    } else {
      console.log('❌ No sessions displayed');
    }
  });
});
