// Test actual dashboard behavior
import { test, expect } from '@playwright/test';

test.describe('Dashboard Behavior Debug', () => {
  test('should check actual dashboard behavior', async ({ page }) => {
    console.log('🔍 Checking actual dashboard behavior...');
    
    // Go to dashboard and wait for it to fully load
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    
    // Wait a bit more for any async operations
    await page.waitForTimeout(3000);
    
    // Check what's actually displayed
    const loadingEl = await page.locator('#loading').isVisible();
    const contentEl = await page.locator('#content').isVisible();
    const errorEl = await page.locator('#error').isVisible();
    
    console.log('Dashboard state:');
    console.log('- Loading visible:', loadingEl);
    console.log('- Content visible:', contentEl);
    console.log('- Error visible:', errorEl);
    
    if (errorEl) {
      const errorText = await page.locator('#error').textContent();
      console.log('Error message:', errorText);
    }
    
    // Check if sessions are displayed
    const sessionsList = await page.locator('#sessions-list').isVisible();
    const sessionItems = await page.locator('#sessions-list .session-item').count();
    
    console.log('Sessions state:');
    console.log('- Sessions list visible:', sessionsList);
    console.log('- Session items count:', sessionItems);
    
    // Check if bests are displayed
    const bestsGrid = await page.locator('#bests-grid').isVisible();
    const bestItems = await page.locator('#bests-grid .best-item').count();
    
    console.log('Bests state:');
    console.log('- Bests grid visible:', bestsGrid);
    console.log('- Best items count:', bestItems);
    
    // Check console for any errors
    const consoleLogs = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleLogs.push(`ERROR: ${msg.text()}`);
      } else if (msg.type() === 'warn') {
        consoleLogs.push(`WARN: ${msg.text()}`);
      }
    });
    
    // Wait to collect console logs
    await page.waitForTimeout(2000);
    
    if (consoleLogs.length > 0) {
      console.log('Console errors/warnings:', consoleLogs);
    }
    
    // Check if the dashboard is actually working
    if (contentEl && !errorEl) {
      console.log('✅ Dashboard is working correctly!');
    } else if (errorEl) {
      console.log('❌ Dashboard is showing error state');
    } else if (loadingEl) {
      console.log('⏳ Dashboard is stuck in loading state');
    }
  });
});
