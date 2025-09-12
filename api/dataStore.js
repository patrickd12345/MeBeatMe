// Shared data store using Vercel KV (if configured), with safe in-memory fallback
import { kv as vercelKv } from '@vercel/kv';

const KV_ENABLED = Boolean(process.env.KV_REST_API_URL && process.env.KV_REST_API_TOKEN) || Boolean(process.env.KV_URL);
const KV_KEY = 'workoutData';

// Fallback in-memory store (per function instance)
if (!global.__fallbackWorkoutData) {
  global.__fallbackWorkoutData = { sessions: [], bestPpi: 0 };
}

function computeBestPpi(sessions) {
  return sessions.length ? Math.max(...sessions.map(s => Number(s.ppi) || 0)) : 0;
}

async function getWorkoutData() {
  if (KV_ENABLED) {
    try {
      const data = await vercelKv.get(KV_KEY);
      if (data && typeof data === 'object') return data;
    } catch (err) {
      console.error('KV get error, falling back to memory:', err.message);
    }
  }
  return global.__fallbackWorkoutData;
}

async function persist(sessions) {
  const state = { sessions, bestPpi: computeBestPpi(sessions) };
  if (KV_ENABLED) {
    try {
      await vercelKv.set(KV_KEY, state);
      return state;
    } catch (err) {
      console.error('KV set error, writing to memory fallback:', err.message);
    }
  }
  global.__fallbackWorkoutData = state;
  return state;
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
    console.log(`Successfully added session: ${newSession.id} (${(newSession.distance/1000).toFixed(2)}km, PPI ${newSession.ppi})`);
    return newSession;
  } catch (error) {
    console.error('Error adding session:', error);
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

// Vercel API handler (optional utility endpoint)
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