// Vercel serverless function for health check
module.exports = function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  // Health check response
  const healthData = {
    status: 'ok',
    version: '1.0.0',
    domain: process.env.FULL_DOMAIN || 'mebeatme.ready2race.run',
    timestamp: Date.now(),
    platform: 'vercel',
    workouts: 0 // This would come from a database in production
  };
  
  res.status(200).json(healthData);
}
