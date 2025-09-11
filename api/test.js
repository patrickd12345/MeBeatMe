// Test endpoint for debugging
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
    try {
      const body = req.body;
      console.log('Request body:', body);
      
      if (!body || !body.code) {
        res.status(400).json({
          success: false,
          error: 'No authorization code provided',
          received: body
        });
        return;
      }
      
      res.status(200).json({
        success: true,
        message: 'Test successful',
        code: body.code
      });
      
    } catch (error) {
      console.error('Test error:', error);
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