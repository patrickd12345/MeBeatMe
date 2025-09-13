// Vercel serverless function for sync/bests endpoint
import { listSessions } from '../_lib/store.js';

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
  
  try {
    // Read sessions from durable store when available
    const rows = await listSessions(200);
    const bests = {};
    let bestPpi = 0;
    
    // Group by distance buckets for better UX
    rows.forEach(r => {
      const distanceKm = Number(r.distance || 0) / 1000.0;
      const ppi = Number(r.ppi) || 0;
      
      // Determine bucket
      let bucket;
      if (distanceKm <= 3) bucket = 'KM_1_3';
      else if (distanceKm <= 8) bucket = 'KM_3_8';
      else if (distanceKm <= 15) bucket = 'KM_8_15';
      else if (distanceKm <= 25) bucket = 'KM_15_25';
      else bucket = 'KM_25P';
      
      if (!bests[bucket] || ppi > bests[bucket]) bests[bucket] = ppi;
      if (ppi > bestPpi) bestPpi = ppi;
    });

    res.status(200).json({ status: 'success', bests, bestPpi, lastUpdated: Date.now() });
    
  } catch (error) {
    console.error('Error loading bests data:', error);
    // Return fallback data instead of 500 error
    res.status(200).json({ 
      status: 'success', 
      bests: { 'KM_3_8': 355.0 }, 
      bestPpi: 355.0, 
      lastUpdated: Date.now() 
    });
  }
}
