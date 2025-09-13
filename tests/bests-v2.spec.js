import { test, expect } from '@playwright/test';

test('bests_v2 returns v2.3 payload', async ({ request }) => {
  const res = await request.get('https://mebeatme.ready2race.run/api/sync/bests_v2');
  expect(res.status()).toBe(200);
  const data = await res.json();
  expect(String(data.message)).toContain('Bests API v2.3');
});


