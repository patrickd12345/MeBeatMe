// Shared data store using in-memory storage (fallback for Vercel KV issues)
// Initialize with hardcoded data and allow runtime additions

// Initialize with default data
let workoutData = {
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

async function getWorkoutData() {
  return workoutData;
}

async function persist(sessions) {
  workoutData.sessions = sessions;
  workoutData.bestPpi = sessions.length ? Math.max(...sessions.map(s => s.ppi)) : 0;
  return workoutData;
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
