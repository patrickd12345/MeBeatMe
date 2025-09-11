// Shared data store for MeBeatMe API
// Using a simple file-based approach for Vercel serverless functions

import fs from 'fs';
import path from 'path';

const DATA_FILE = '/tmp/mebeatme_data.json';

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

function loadData() {
  try {
    if (fs.existsSync(DATA_FILE)) {
      const data = fs.readFileSync(DATA_FILE, 'utf8');
      workoutData = JSON.parse(data);
    }
  } catch (error) {
    console.error('Error loading data:', error);
  }
}

function saveData() {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(workoutData, null, 2));
  } catch (error) {
    console.error('Error saving data:', error);
  }
}

function getWorkoutData() {
  loadData();
  return workoutData;
}

function updateWorkoutData(newData) {
  loadData();
  workoutData = { ...workoutData, ...newData };
  
  // Recalculate best PPI across all sessions
  if (workoutData.sessions.length > 0) {
    const bestPpi = Math.max(...workoutData.sessions.map(session => session.ppi));
    workoutData.bestPpi = bestPpi;
  }
  
  saveData();
  return workoutData;
}

function addSession(session) {
  loadData();
  
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
  
  saveData();
  return newSession;
}

function deleteSession(sessionId) {
  loadData();
  
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
  
  saveData();
  return deletedSession;
}

export {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};
