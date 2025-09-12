// Test dashboard display with multiple sessions
import { test, expect } from '@playwright/test';

test.describe('Dashboard Display Test', () => {
  test('should display multiple sessions on dashboard', async ({ page }) => {
    // Go to the production dashboard
    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    
    // Wait for the page to load
    await page.waitForLoadState('networkidle');
    
    // Wait for the sessions to load
    await page.waitForSelector('#sessions-list', { timeout: 10000 });
    
    // Get the sessions list
    const sessionsList = page.locator('#sessions-list');
    await expect(sessionsList).toBeVisible();
    
    // Count the sessions displayed
    const sessionItems = page.locator('#sessions-list .session-item');
    const sessionCount = await sessionItems.count();
    
    console.log(`Dashboard shows ${sessionCount} sessions`);
    
    // Should have more than 1 session now
    expect(sessionCount).toBeGreaterThan(1);
    
    // Check if sessions have proper data
    const firstSession = sessionItems.first();
    await expect(firstSession).toBeVisible();
    
    // Check for session details
    const sessionDetails = firstSession.locator('.session-details');
    await expect(sessionDetails).toBeVisible();
    
    // Should not show "undefined" for activity name
    const activityName = sessionDetails.locator('div').first();
    const nameText = await activityName.textContent();
    console.log('First session name:', nameText);
    expect(nameText).not.toContain('undefined');
    
    // Should not show "Bucket: undefined"
    const bucketText = await sessionDetails.textContent();
    expect(bucketText).not.toContain('Bucket: undefined');
  });
});
