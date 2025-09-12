// Vercel serverless function for sync/bests endpoint
const { getWorkoutData } = require('../dataStore.js');

async function handler(req, res) {
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
  
  try {
    // Get real data from data store
    const workoutData = await getWorkoutData();

    // Build bests by actual distances (labels like "5.94 km") instead of legacy buckets
    const bests = {};

    workoutData.sessions.forEach(session => {
      const distanceKm = (session.distance || 0) / 1000;
      const label = `${distanceKm.toFixed(2)} km`;
      const ppi = Number(session.ppi) || 0;
      if (!bests[label] || ppi > bests[label]) {
        bests[label] = ppi;
      }
    });

    // Also compute the single best PPI overall
    const bestPpi = workoutData.sessions.length
      ? Math.max(...workoutData.sessions.map(s => Number(s.ppi) || 0))
      : 0;

    const bestsData = {
      status: 'success',
      bests,
      bestPpi,
      lastUpdated: Date.now()
    };

    res.status(200).json(bestsData);
    
  } catch (error) {
    console.error('Error loading bests data:', error);
    res.status(500).json({
      status: 'error',
      error: 'Failed to load bests data',
      details: error.message
    });
  }
}

module.exports = handler;
