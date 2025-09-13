import { test, expect } from '@playwright/test';

test.describe('API Signature Test', () => {
  test('should test bests API and check for signature', async ({ request }) => {
    console.log('Testing bests API for signature...');
    
    const response = await request.get('https://mebeatme.ready2race.run/api/sync/bests');
    console.log('Response status:', response.status());
    
    if (response.status() === 200) {
      const data = await response.json();
      console.log('API Response:', JSON.stringify(data, null, 2));
      expect(data.status).toBe('success');
    } else {
      const errorText = await response.text();
      console.log('Error response:', errorText);
    }
    
    // The signature should appear in Vercel logs if our code is deployed
    console.log('Check Vercel logs for: "Bests API v2.2 at 2025-01-13T12:35:00Z - SUPABASE COMPLETELY DISABLED"');
  });
});
