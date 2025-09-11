// Vercel serverless function for sync/sessions endpoint

// In-memory storage for this session
let sessionStorage = {
  sessions: [
    {
      id: 'hardcoded_run',
      distance: 5940,
      duration: 2498,
      ppi: 355.0,
      createdAt: 1757520000000
    }
  ],
  bestPpi: 355.0
};

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
  
  if (req.method === 'POST') {
    // Handle adding a session directly
    try {
      const workoutData = req.body;
      const distance = workoutData.distanceMeters || 0;
      const time = workoutData.elapsedSeconds || 0;
      const timestamp = workoutData.startedAtEpochMs || Date.now();
      
      // Calculate PPI using Purdy formula
      const ppi = calculatePPI(distance, time);
      
      const newSession = {
        id: `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        distance: distance,
        duration: time,
        ppi: ppi,
        createdAt: timestamp
      };
      
      sessionStorage.sessions.push(newSession);
      
      // Update best PPI if this is better
      if (ppi > sessionStorage.bestPpi) {
        sessionStorage.bestPpi = ppi;
      }
      
      console.log(`Added session: ${JSON.stringify(newSession)}`);
      console.log(`Total sessions: ${sessionStorage.sessions.length}`);
      
      res.status(200).json({
        status: 'success',
        message: 'Session added successfully',
        ppi: ppi.toFixed(1),
        sessionId: newSession.id
      });
      
    } catch (error) {
      console.error('Error processing session:', error);
      res.status(500).json({
        status: 'error',
        message: 'Internal server error'
      });
    }
  } else if (req.method === 'GET') {
    // Return session data
    const sessionsData = {
      status: 'success',
      sessions: sessionStorage.sessions,
      count: sessionStorage.sessions.length,
      bestPpi: sessionStorage.bestPpi
    };
    
    res.status(200).json(sessionsData);
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
