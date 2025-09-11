// Vercel serverless function for sync/bests endpoint
import { getWorkoutData } from '../shared/dataStore.js';

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
  
  try {
    // Get real data from data store
    const workoutData = getWorkoutData();
    
    // Calculate best PPIs by distance ranges (simplified for now)
    const bests = {};
    
    // Group sessions by distance ranges and find best PPI for each
    workoutData.sessions.forEach(session => {
      const distanceKm = session.distance / 1000;
      let bucket;
      
      if (distanceKm <= 3) {
        bucket = 'KM_1_3';
      } else if (distanceKm <= 8) {
        bucket = 'KM_3_8';
      } else if (distanceKm <= 15) {
        bucket = 'KM_8_15';
      } else if (distanceKm <= 25) {
        bucket = 'KM_15_25';
      } else {
        bucket = 'KM_25P';
      }
      
      if (!bests[bucket] || session.ppi > bests[bucket]) {
        bests[bucket] = session.ppi;
      }
    });
    
    const bestsData = {
      status: 'success',
      bests: bests,
      bestPpi: workoutData.bestPpi,
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
