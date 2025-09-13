import { test, expect } from '@playwright/test';

test('bests_v2 returns v2.4 payload (preview domain)', async ({ request }) => {
  const res = await request.get('https://mebeatme-bhdkzxsow-patrick-duchesneaus-projects.vercel.app/api/bests_v2');
  expect(res.status()).toBe(200);
  const data = await res.json();
  expect(String(data.message)).toContain('Bests API v2.4');
});


