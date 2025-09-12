// Shared data store using global state (persists across serverless function calls)
// Initialize with hardcoded data and allow runtime additions

// Use global state that persists across Vercel serverless function calls
if (!global.workoutData) {
  global.workoutData = {
    sessions: [],
    bestPpi: 0
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
      createdAt: session.createdAt || Date.now()
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

// Vercel API handler
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  try {
    if (req.method === 'GET') {
      const data = await getWorkoutData();
      res.status(200).json(data);
    } else if (req.method === 'POST') {
      const { action, ...params } = req.body;
      
      if (action === 'addSession') {
        const session = await addSession(params.session);
        res.status(201).json(session);
      } else if (action === 'deleteSession') {
        const removed = await deleteSession(params.sessionId);
        res.status(200).json(removed);
      } else if (action === 'updateWorkoutData') {
        const data = await updateWorkoutData(params.data);
        res.status(200).json(data);
      } else {
        res.status(400).json({ error: 'Invalid action' });
      }
    } else {
      res.status(405).json({ error: 'Method not allowed' });
    }
  } catch (error) {
    console.error('Data store API error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}

export {
  getWorkoutData,
  updateWorkoutData,
  addSession,
  deleteSession
};