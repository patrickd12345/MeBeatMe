// Test production API endpoints directly
import { test, expect } from '@playwright/test';

test.describe('Production API Tests', () => {
  test('should get sessions from production API', async ({ request }) => {
    const response = await request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    console.log('Production sessions:', JSON.stringify(data, null, 2));
    
    expect(data.status).toBe('success');
    expect(data.sessions).toBeDefined();
    expect(Array.isArray(data.sessions)).toBe(true);
    
    // Log the actual count
    console.log(`Found ${data.count} sessions in production`);
  });

  test('should test Strava import endpoint', async ({ request }) => {
    // Test with invalid token to see if endpoint responds
    const response = await request.post('https://mebeatme.ready2race.run/api/strava/import', {
      data: {
        access_token: 'invalid_token_for_testing',
        count: 5
      }
    });
    
    const data = await response.json();
    console.log('Strava import response:', JSON.stringify(data, null, 2));
    
    // Should get 401 error for invalid token, but endpoint should respond
    expect(response.status()).toBe(400);
    expect(data.success).toBe(false);
  });

  test('should test bests API', async ({ request }) => {
    const response = await request.get('https://mebeatme.ready2race.run/api/sync/bests');
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    console.log('Production bests:', JSON.stringify(data, null, 2));
    
    expect(data.status).toBe('success');
  });
});
