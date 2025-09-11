// Shared data store for MeBeatMe API
// Using in-memory storage with initialization from committed data

import fs from 'fs';
import path from 'path';

// Try to load initial data from committed file, fallback to default
function loadInitialData() {
  try {
    const DATA_FILE = path.join(process.cwd(), 'data', 'workout-data.json');
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      return JSON.parse(data);
    }
  } catch (error) {
    console.error('Error loading initial data file:', error);
  }
  
  // Fallback to default data
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

// Initialize data (this will be the committed data in production)
let workoutData = loadInitialData();

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
