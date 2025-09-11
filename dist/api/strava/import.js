// Vercel serverless function for Strava activity import
export default function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method === 'POST') {
    // Handle Strava activity import
    try {
      const { access_token, count, type, days } = req.body;
      
      // Mock import response for demonstration
      const importResult = {
        success: true,
        imported: 3,
        total: 3,
        activities: [
          {
            name: 'Morning Run',
            distance: '5.0',
            time: '25:30',
            success: true
          },
          {
            name: 'Evening Run',
            distance: '8.5',
            time: '42:15',
            success: true
          },
          {
            name: 'Weekend Long Run',
            distance: '15.2',
            time: '1:18:45',
            success: true
          }
        ]
      };
      
      res.status(200).json(importResult);
      
    } catch (error) {
      console.error('Error handling Strava import:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error'
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
