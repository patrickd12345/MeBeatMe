// Vercel serverless function for sync/bests endpoint
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
  
  // Return best PPI data (hardcoded for now)
  const bestsData = {
    status: 'success',
    bests: {
      KM_3_8: 355.0 // Return in the old format the dashboard expects
    },
    lastUpdated: Date.now()
  };
  
  res.status(200).json(bestsData);
}
