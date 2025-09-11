// Shared data store for MeBeatMe API
// In production, this would be replaced with a real database

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
    id: `session_${Date.now()}`,
    ...session,
    createdAt: Date.now()
  };
  
  workoutData.sessions.push(newSession);
  
  // Update best PPI if this is better
  if (session.ppi > workoutData.bestPpi) {
    workoutData.bestPpi = session.ppi;
  }
  
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

module.exports = {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};
