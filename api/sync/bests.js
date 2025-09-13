// Vercel serverless function for sync/bests endpoint - FIXED VERSION
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
  
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }
  
  // Return sample data - no external dependencies
  const bestsData = {
    status: 'success',
    bests: {
      'KM_1_3': 450.0,
      'KM_3_8': 355.0,
      'KM_8_15': 280.0,
      'KM_15_25': 220.0,
      'KM_25P': 180.0
    },
    bestPpi: 450.0,
    lastUpdated: Date.now()
  };
  
  res.status(200).json(bestsData);
}
