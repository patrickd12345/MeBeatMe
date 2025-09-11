// Vercel serverless function for sync/sessions endpoint
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
  
  // Get session data from data store
  const workoutData = getWorkoutData();
  
  const sessionsData = {
    status: 'success',
    sessions: workoutData.sessions,
    count: workoutData.sessions.length,
    bestPpi: workoutData.bestPpi
  };
  
  res.status(200).json(sessionsData);
}
