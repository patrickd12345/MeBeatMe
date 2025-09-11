// Shared data store for MeBeatMe API
// Using in-memory storage with initialization from committed data

import fs from 'fs';
import path from 'path';

// Try to load initial data from committed file, fallback to default
function loadInitialData() {
  try {
    const DATA_FILE = path.join(process.cwd(), 'data', 'workout-data.json');
    console.log('Looking for data file at:', DATA_FILE);
    console.log('Current working directory:', process.cwd());
    
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      const parsed = JSON.parse(data);
      console.log('Loaded data file with', parsed.sessions.length, 'sessions');
      return parsed;
    } else {
      console.log('Data file not found at:', DATA_FILE);
    }
  } catch (error) {
    console.error('Error loading initial data file:', error);
  }
  
  // Fallback to default data
  console.log('Using fallback default data');
  return {
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
}

// Initialize data (hardcoded imported activities for testing)
let workoutData = {
  sessions: [
    {
      id: 'session_1757609719866_hc3tt98kv',
      distance: 5000,
      duration: 1500,
      ppi: 127.51670370370368,
      createdAt: 1757609719866,
      source: 'strava',
      activityId: 'Morning Run',
      name: 'Morning Run'
    },
    {
      id: 'session_1757609719866_7ek9q5gxu',
      distance: 10000,
      duration: 3000,
      ppi: 143.6034226296296,
      createdAt: 1757609719866,
      source: 'strava',
      activityId: 'Long Run',
      name: 'Long Run'
    },
    {
      id: 'session_1757609719867_gh5rhgew2',
      distance: 3000,
      duration: 900,
      ppi: 115.81247374020214,
      createdAt: 1757609719867,
      source: 'strava',
      activityId: 'Speed Work',
      name: 'Speed Work'
    },
    {
      id: 'session_1757609719867_4zl8l7etk',
      distance: 8000,
      duration: 2400,
      ppi: 138.21463698658872,
      createdAt: 1757609719867,
      source: 'strava',
      activityId: 'Tempo Run',
      name: 'Tempo Run'
    },
    {
      id: 'session_1757609719868_8s5qmc8zx',
      distance: 15000,
      duration: 4500,
      ppi: 159.8729570719114,
      createdAt: 1757609719868,
      source: 'strava',
      activityId: 'Long Run 2',
      name: 'Long Run 2'
    }
  ],
  bestPpi: 159.8729570719114
};

function getWorkoutData() {
  return workoutData;
}

function updateWorkoutData(newData) {
  workoutData = { ...workoutData, ...newData };
  
  // Recalculate best PPI across all sessions
  if (workoutData.sessions.length > 0) {
    const bestPpi = Math.max(...workoutData.sessions.map(session => session.ppi));
    workoutData.bestPpi = bestPpi;
  }
  
  return workoutData;
}

function addSession(session) {
  const newSession = {
    id: `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    ...session,
    createdAt: Date.now()
  };
  
  workoutData.sessions.push(newSession);
  
  // Update best PPI if this is better
  if (session.ppi > workoutData.bestPpi) {
    workoutData.bestPpi = session.ppi;
  }
  
  console.log(`Added session: ${JSON.stringify(newSession)}`);
  console.log(`Total sessions: ${workoutData.sessions.length}`);
  
  return newSession;
}

function deleteSession(sessionId) {
  const sessionIndex = workoutData.sessions.findIndex(session => session.id === sessionId);
  if (sessionIndex === -1) {
    return null;
  }
  
  const deletedSession = workoutData.sessions.splice(sessionIndex, 1)[0];
  
  // Recalculate best PPI across all remaining sessions
  if (workoutData.sessions.length > 0) {
    workoutData.bestPpi = Math.max(...workoutData.sessions.map(session => session.ppi));
  } else {
    workoutData.bestPpi = 0;
  }
  
  return deletedSession;
}

export {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};
