// Vercel serverless function for Strava integration
module.exports = async function handler(req, res) {
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
      
      console.log('Received code:', code);
      
      if (!code) {
        res.status(400).json({
          success: false,
          error: 'No authorization code provided'
        });
        return;
      }
      
      // Exchange code for real Strava tokens
      try {
        const tokenResponse = await fetch('https://www.strava.com/oauth/token', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            client_id: process.env.STRAVA_CLIENT_ID || '157217',
            client_secret: process.env.STRAVA_CLIENT_SECRET || '3652b26562c819e1a13ebb34e517e707dab939b2',
            code: code,
            grant_type: 'authorization_code'
          })
        });
        
        if (!tokenResponse.ok) {
          const errorText = await tokenResponse.text();
          console.error('Strava token exchange failed:', tokenResponse.status, errorText);
          res.status(400).json({
            success: false,
            error: 'Failed to exchange authorization code with Strava',
            details: `HTTP ${tokenResponse.status}: ${errorText}`
          });
          return;
        }
        
        const tokenData = await tokenResponse.json();
        
        if (tokenData.access_token) {
          res.status(200).json({
            success: true,
            access_token: tokenData.access_token,
            refresh_token: tokenData.refresh_token,
            expires_at: tokenData.expires_at
          });
        } else {
          res.status(400).json({
            success: false,
            error: 'Failed to get access token from Strava',
            details: tokenData
          });
        }
      } catch (fetchError) {
        console.error('Fetch error:', fetchError);
        res.status(500).json({
          success: false,
          error: 'Network error calling Strava API',
          details: fetchError.message
        });
        return;
      }
      
    } catch (error) {
      console.error('Error handling Strava token exchange:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        details: error.message
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
