// Shared data store using global state (persists across serverless function calls)
// Initialize with hardcoded data and allow runtime additions

// Use global state that persists across Vercel serverless function calls
if (!global.workoutData) {
  global.workoutData = {
    sessions: [
      {
        id: 'hardcoded_run',
        distance: 5940,
        duration: 2498,
        ppi: 355,
        createdAt: 1757520000000,
        name: 'Sample Run'
      }
    ],
    bestPpi: 355
  };
}

async function getWorkoutData() {
  return global.workoutData;
}

async function persist(sessions) {
  global.workoutData.sessions = sessions;
  global.workoutData.bestPpi = sessions.length ? Math.max(...sessions.map(s => s.ppi)) : 0;
  return global.workoutData;
}

async function updateWorkoutData(newData) {
  const current = await getWorkoutData();
  const merged = { ...current, ...newData };
  return await persist(merged.sessions || current.sessions);
}

async function addSession(session) {
  try {
    const current = await getWorkoutData();
    const newSession = {
      id: `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      ...session,
      createdAt: Date.now()
    };
    const sessions = [newSession, ...current.sessions];
    await persist(sessions);
    console.log(`Successfully added session: ${newSession.id} to memory store`);
    return newSession;
  } catch (error) {
    console.error('Error adding session to memory store:', error);
    throw error;
  }
}

async function deleteSession(sessionId) {
  const current = await getWorkoutData();
  const sessions = current.sessions.filter(s => s.id !== sessionId);
  await persist(sessions);
  const removed = current.sessions.find(s => s.id === sessionId) || null;
  return removed;
}

export {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};
