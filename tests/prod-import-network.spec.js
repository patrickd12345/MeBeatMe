import { test, expect } from '@playwright/test';

test.describe('Production Import Network Probe', () => {
  test('captures console and /api/strava/import traffic', async ({ page }) => {
    const events = [];

    page.on('console', msg => {
      events.push({ type: 'console', level: msg.type(), text: msg.text() });
    });

    page.on('request', req => {
      const url = req.url();
      if (url.includes('/api/strava/import') || url.includes('/api/sync/sessions') || url.includes('/api/sync/bests')) {
        events.push({ type: 'request', method: req.method(), url });
      }
    });

    page.on('response', async res => {
      const url = res.url();
      if (url.includes('/api/strava/import') || url.includes('/api/sync/sessions') || url.includes('/api/sync/bests')) {
        let body;
        try { body = await res.text(); } catch { body = '<non-text>'; }
        events.push({ type: 'response', status: res.status(), url, body });
      }
    });

    await page.goto('https://mebeatme.ready2race.run/dashboard.html');
    await page.waitForLoadState('networkidle');
    // Give dashboard time to auto-load
    await page.waitForTimeout(2000);

    // Open Strava modal
    const openBtn = page.locator('button:has-text("Import from Strava")');
    await expect(openBtn).toBeVisible();
    await openBtn.click();

    // If connect button exists, click it to open popup (we won't automate oauth)
    const connect = page.locator('button:has-text("Connect to Strava")');
    if (await connect.isVisible()) {
      await connect.click();
      // Wait briefly to record popup attempt and any messages
      await page.waitForTimeout(1500);
    }

    // Also directly probe the import endpoint with no token to see server behavior
    const probe = await page.request.post('https://mebeatme.ready2race.run/api/strava/import', {
      data: { count: 1, type: 'Run', days: 7 }
    });
    events.push({ type: 'direct-import', status: probe.status(), body: await probe.text() });

    // Print a compact log to stdout for CI visibility
    // eslint-disable-next-line no-console
    console.log(JSON.stringify(events, null, 2));
  });
});

