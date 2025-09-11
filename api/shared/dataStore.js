// Shared data store for MeBeatMe API
// Using a simple in-memory approach with session persistence

let workoutData = {
  sessions: [
    {
      id: 'hardcoded_run',
      distance: 5940,
      duration: 2498,
      ppi: 355.0,
      createdAt: 1757520000000
    }
  ],
  bestPpi: 355.0 // Single best PPI across all distances
};

// Global variable to persist data across function calls
if (typeof global.workoutData === 'undefined') {
  global.workoutData = workoutData;
}

function getWorkoutData() {
  return global.workoutData;
}

function updateWorkoutData(newData) {
  global.workoutData = { ...global.workoutData, ...newData };
  
  // Recalculate best PPI across all sessions
  if (global.workoutData.sessions.length > 0) {
    const bestPpi = Math.max(...global.workoutData.sessions.map(session => session.ppi));
    global.workoutData.bestPpi = bestPpi;
  }
  
  return global.workoutData;
}

function addSession(session) {
  const newSession = {
    id: `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    ...session,
    createdAt: Date.now()
  };
  
  global.workoutData.sessions.push(newSession);
  
  // Update best PPI if this is better
  if (session.ppi > global.workoutData.bestPpi) {
    global.workoutData.bestPpi = session.ppi;
  }
  
  console.log(`Added session: ${JSON.stringify(newSession)}`);
  console.log(`Total sessions: ${global.workoutData.sessions.length}`);
  
  return newSession;
}

function deleteSession(sessionId) {
  const sessionIndex = global.workoutData.sessions.findIndex(session => session.id === sessionId);
  if (sessionIndex === -1) {
    return null;
  }
  
  const deletedSession = global.workoutData.sessions.splice(sessionIndex, 1)[0];
  
  // Recalculate best PPI across all remaining sessions
  if (global.workoutData.sessions.length > 0) {
    global.workoutData.bestPpi = Math.max(...global.workoutData.sessions.map(session => session.ppi));
  } else {
    global.workoutData.bestPpi = 0;
  }
  
  return deletedSession;
}

export {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};
