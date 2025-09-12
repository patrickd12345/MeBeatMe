// Test adding sessions to production API
import { test, expect } from '@playwright/test';

test.describe('Production Session Management', () => {
  test('should add a session and verify it persists', async ({ request }) => {
    // First, get initial sessions
    const initialResponse = await request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const initialData = await initialResponse.json();
    console.log('Initial sessions count:', initialData.count);
    
    // Add a test session
    const addResponse = await request.post('https://mebeatme.ready2race.run/api/sync/sessions', {
      data: {
        distanceMeters: 5000,
        elapsedSeconds: 1800, // 30 minutes
        startedAtEpochMs: Date.now()
      }
    });
    
    expect(addResponse.status()).toBe(200);
    const addData = await addResponse.json();
    console.log('Add session response:', JSON.stringify(addData, null, 2));
    
    // Wait a moment for the session to be processed
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Check if the session was added
    const finalResponse = await request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const finalData = await finalResponse.json();
    console.log('Final sessions count:', finalData.count);
    console.log('Final sessions:', JSON.stringify(finalData.sessions, null, 2));
    
    // The count should have increased
    expect(finalData.count).toBeGreaterThan(initialData.count);
  });
});
