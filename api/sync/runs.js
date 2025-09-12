// Vercel serverless function for sync/runs endpoint
const { addSession, deleteSession } = require('../dataStore.js');

module.exports = async function handler(req, res) {
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
    // Handle workout submission
    try {
      const workoutData = Array.isArray(req.body) ? req.body[0] : req.body;
      
      // Extract workout details
      const distance = workoutData.distanceMeters || 0;
      const time = workoutData.elapsedSeconds || 0;
      const timestamp = workoutData.startedAtEpochMs || Date.now();
      
      // Calculate PPI using Purdy formula
      const ppi = calculatePPI(distance, time);
      
      // Create session object
      const sessionData = {
        distance: distance,
        duration: time,
        ppi: ppi,
        createdAt: timestamp
      };
      
      // Add to data store
      const newSession = await addSession(sessionData);

      console.log(`New workout added: ${distance}m in ${time}s, PPI: ${ppi.toFixed(1)}`);

      res.status(200).json({
        status: 'success',
        message: 'Workout added successfully',
        ppi: ppi.toFixed(1),
        sessionId: newSession.id
      });
      
    } catch (error) {
      console.error('Error processing workout:', error);
      res.status(500).json({
        status: 'error',
        message: 'Internal server error'
      });
    }
  } else if (req.method === 'DELETE') {
    // Handle workout deletion
    try {
      const workoutId = req.query.id || req.url.split('/').pop();
      
      const deletedSession = await deleteSession(workoutId);

      if (deletedSession) {
        console.log(`Workout deleted: ${workoutId}`);
        res.status(200).json({
          status: 'success',
          message: 'Workout deleted successfully'
        });
      } else {
        res.status(404).json({
          status: 'error',
          message: 'Workout not found'
        });
      }
      
    } catch (error) {
      console.error('Error deleting workout:', error);
      res.status(500).json({
        status: 'error',
        message: 'Internal server error'
      });
    }
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}

// Purdy Points calculation
function calculatePPI(distanceMeters, timeSeconds) {
  const baselineTime = getInterpolatedBaselineTime(distanceMeters);
  const ratio = baselineTime / timeSeconds;
  return 1000.0 * Math.pow(ratio, 3);
}

function getInterpolatedBaselineTime(distanceMeters) {
  const baselines = [
    [1500, 210],    // 3:30
    [5000, 755],    // 12:35 
    [10000, 1571],  // 26:11
    [21097, 3540],  // 59:00
    [42195, 7460]   // 2:04:20
  ];
  
  if (distanceMeters <= baselines[0][0]) {
    return baselines[0][1];
  }
  if (distanceMeters >= baselines[baselines.length - 1][0]) {
    return baselines[baselines.length - 1][1];
  }
  
  for (let i = 0; i < baselines.length - 1; i++) {
    const currentDist = baselines[i][0];
    const nextDist = baselines[i + 1][0];
    
    if (distanceMeters >= currentDist && distanceMeters <= nextDist) {
      const logDist1 = Math.log(currentDist);
      const logDist2 = Math.log(nextDist);
      const logTime1 = Math.log(baselines[i][1]);
      const logTime2 = Math.log(baselines[i + 1][1]);
      const logDistTarget = Math.log(distanceMeters);
      
      const ratio = (logDistTarget - logDist1) / (logDist2 - logDist1);
      const logTimeTarget = logTime1 + ratio * (logTime2 - logTime1);
      
      return Math.exp(logTimeTarget);
    }
  }
  
  return baselines[baselines.length - 1][1];
}
