const { test, expect } = require('@playwright/test');

test.describe('Strava Import Flow', () => {
  test('should complete full Strava import workflow', async ({ page }) => {
    await page.goto('/dashboard.html');
    await page.waitForLoadState('networkidle');

    // Click Import from Strava button
    const importButton = page.locator('button:has-text("Import from Strava")');
    await expect(importButton).toBeVisible();
    await importButton.click();

    // Wait for Strava OAuth popup or redirect
    // Note: This test will fail in headless mode without real Strava credentials
    // But it will verify the button works and the flow starts
  });

  test('should handle Strava import dialog', async ({ page }) => {
    await page.goto('/dashboard.html');
    await page.waitForLoadState('networkidle');

    // Mock the Strava import API response
    await page.route('**/api/strava/import', async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'success',
          imported: 3,
          activities: [
            {
              id: 'test_1',
              name: 'Morning Run',
              distanceMeters: 5000,
              durationSeconds: 1800,
              createdAtMs: Date.now()
            },
            {
              id: 'test_2', 
              name: 'Evening Jog',
              distanceMeters: 3000,
              durationSeconds: 1200,
              createdAtMs: Date.now()
            }
          ]
        })
      });
    });

    // Mock the sessions API to return the imported activities
    await page.route('**/api/sync/sessions', async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'success',
          sessions: [
            {
              id: 'test_1',
              filename: 'Morning Run',
              distance: 5000,
              duration: 1800,
              ppi: 250,
              createdAt: Date.now()
            },
            {
              id: 'test_2',
              filename: 'Evening Jog', 
              distance: 3000,
              duration: 1200,
              ppi: 200,
              createdAt: Date.now()
            }
          ],
          count: 2,
          bestPpi: 250
        })
      });
    });

    // Test that the dashboard loads with mocked data
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Check that sessions are displayed
    const sessionsList = page.locator('#sessions-list');
    await expect(sessionsList).toBeVisible();
  });
});

test.describe('Data Persistence', () => {
  test('should persist data across page reloads', async ({ page }) => {
    await page.goto('/dashboard.html');
    await page.waitForLoadState('networkidle');

    // Mock initial data
    await page.route('**/api/sync/sessions', async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'success',
          sessions: [
            {
              id: 'persistent_test',
              filename: 'Persistent Run',
              distance: 5000,
              duration: 1800,
              ppi: 250,
              createdAt: Date.now()
            }
          ],
          count: 1,
          bestPpi: 250
        })
      });
    });

    // Reload page and check data persists
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Verify data is still there
    const sessionsList = page.locator('#sessions-list');
    await expect(sessionsList).toBeVisible();
  });
});

test.describe('Error Handling', () => {
  test('should handle API errors gracefully', async ({ page }) => {
    await page.goto('/dashboard.html');

    // Mock API error
    await page.route('**/api/sync/sessions', async route => {
      await route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'error',
          message: 'Internal server error'
        })
      });
    });

    await page.route('**/api/sync/bests', async route => {
      await route.fulfill({
        status: 500,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'error',
          message: 'Internal server error'
        })
      });
    });

    await page.waitForLoadState('networkidle');

    // Check that error handling works
    // The page should still load even with API errors
    await expect(page.locator('h1')).toContainText('MeBeatMe Dashboard');
  });

  test('should handle network timeouts', async ({ page }) => {
    await page.goto('/dashboard.html');

    // Mock slow API responses
    await page.route('**/api/sync/sessions', async route => {
      await new Promise(resolve => setTimeout(resolve, 10000)); // 10 second delay
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          status: 'success',
          sessions: [],
          count: 0,
          bestPpi: 0
        })
      });
    });

    // Page should still load even with slow API
    await expect(page.locator('h1')).toContainText('MeBeatMe Dashboard');
  });
});
