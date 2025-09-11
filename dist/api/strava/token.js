// Vercel serverless function for Strava integration
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
    // Handle Strava token exchange
    try {
      const { code } = req.body;
      
      if (!code) {
        res.status(400).json({
          success: false,
          error: 'No authorization code provided'
        });
        return;
      }
      
      // In a real implementation, you'd exchange the code for tokens
      // For now, return mock tokens
      res.status(200).json({
        success: true,
        access_token: 'mock_access_token',
        refresh_token: 'mock_refresh_token'
      });
      
    } catch (error) {
      console.error('Error handling Strava token exchange:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error'
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
