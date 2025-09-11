// Vercel serverless function for sync/sessions endpoint
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
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  // Return session data (hardcoded for now)
  const sessionsData = {
    status: 'success',
    sessions: [
      {
        id: 'hardcoded_run',
        distance: 5940,
        duration: 2498,
        ppi: 355.0,
        createdAt: 1757520000000
      }
    ],
    count: 1
  };
  
  res.status(200).json(sessionsData);
}
