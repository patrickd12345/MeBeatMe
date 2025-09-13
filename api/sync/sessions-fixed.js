// Simple sessions API - completely bypasses Supabase
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method === 'GET') {
    // Return sample data - no external dependencies
    const sessionsData = {
      status: 'success',
      sessions: [{
        id: 'sample_run',
        filename: 'Sample 5K Run',
        distance: 5940,
        duration: 2498,
        ppi: 355.0,
        createdAt: Date.now()
      }],
      count: 1,
      bestPpi: 355.0
    };
    
    res.status(200).json(sessionsData);
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
