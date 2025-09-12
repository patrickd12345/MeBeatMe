// Test Strava import simulation
import { test, expect } from '@playwright/test';

test.describe('Strava Import Simulation', () => {
  test('should simulate successful Strava import', async ({ request }) => {
    // Get initial count
    const initialResponse = await request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const initialData = await initialResponse.json();
    console.log('Initial sessions count:', initialData.count);
    
    // Simulate what Strava import should do - add multiple sessions directly
    const mockStravaActivities = [
      {
        id: 'strava_1',
        name: 'Morning Run',
        distance: 5000,
        moving_time: 1800,
        start_date: new Date().toISOString()
      },
      {
        id: 'strava_2', 
        name: 'Evening Run',
        distance: 3000,
        moving_time: 1200,
        start_date: new Date().toISOString()
      },
      {
        id: 'strava_3',
        name: 'Long Run',
        distance: 10000,
        moving_time: 3600,
        start_date: new Date().toISOString()
      }
    ];
    
    // Add each activity directly to test the addSession function
    for (const activity of mockStravaActivities) {
      const sessionData = {
        distance: activity.distance,
        duration: activity.moving_time,
        ppi: 300, // Mock PPI
        createdAt: new Date(activity.start_date).getTime(),
        source: 'strava',
        activityId: activity.id,
        name: activity.name
      };
      
      // Use the sessions endpoint to add each activity
      const addResponse = await request.post('https://mebeatme.ready2race.run/api/sync/sessions', {
        data: {
          distanceMeters: activity.distance,
          elapsedSeconds: activity.moving_time,
          startedAtEpochMs: new Date(activity.start_date).getTime()
        }
      });
      
      console.log(`Added ${activity.name}:`, addResponse.status());
    }
    
    // Wait for all sessions to be processed
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Check final count
    const finalResponse = await request.get('https://mebeatme.ready2race.run/api/sync/sessions');
    const finalData = await finalResponse.json();
    console.log('Final sessions count:', finalData.count);
    console.log('Final sessions:', finalData.sessions.map(s => s.id));
    
    // Should have added 3 more sessions
    expect(finalData.count).toBeGreaterThanOrEqual(initialData.count + 3);
  });
});
