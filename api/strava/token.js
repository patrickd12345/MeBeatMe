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
  
  // GET: return access token from cookies if present (used by dashboard)
  if (req.method === 'GET') {
    try {
      const cookieHeader = req.headers.cookie || '';
      const cookies = Object.fromEntries(cookieHeader.split(';').map(c => {
        const idx = c.indexOf('=');
        if (idx === -1) return [c.trim(), ''];
        const name = c.slice(0, idx).trim();
        const value = decodeURIComponent(c.slice(idx + 1));
        return [name, value];
      }));

      const accessToken = cookies['strava_access_token'] || null;
      const refreshToken = cookies['strava_refresh_token'] || null;
      const expiresAt = cookies['strava_expires_at'] ? Number(cookies['strava_expires_at']) : null;

      if (!accessToken) {
        res.status(200).json({ success: false, error: 'No access token in cookies' });
        return;
      }

      res.status(200).json({ success: true, access_token: accessToken, refresh_token: refreshToken, expires_at: expiresAt });
    } catch (err) {
      res.status(500).json({ success: false, error: 'Failed to read tokens from cookies', details: err.message });
    }
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
