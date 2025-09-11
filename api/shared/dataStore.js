// Shared data store backed by Vercel KV (serverless-safe persistence)
import { kv } from '@vercel/kv';

const KV_SESSIONS_KEY = 'mbm:sessions';
const KV_BESTPPI_KEY = 'mbm:bestPpi';

async function getWorkoutData() {
  const sessions = (await kv.get(KV_SESSIONS_KEY)) || [];
  const bestPpi = (await kv.get(KV_BESTPPI_KEY)) || (sessions.length ? Math.max(...sessions.map(s => s.ppi)) : 0);
  return { sessions, bestPpi };
}

async function persist(sessions) {
  await kv.set(KV_SESSIONS_KEY, sessions);
  const bestPpi = sessions.length ? Math.max(...sessions.map(s => s.ppi)) : 0;
  await kv.set(KV_BESTPPI_KEY, bestPpi);
  return { sessions, bestPpi };
}

async function updateWorkoutData(newData) {
  const current = await getWorkoutData();
  const merged = { ...current, ...newData };
  return await persist(merged.sessions || current.sessions);
}

async function addSession(session) {
  const current = await getWorkoutData();
  const newSession = {
    id: `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    ...session,
    createdAt: Date.now()
  };
  const sessions = [newSession, ...current.sessions];
  await persist(sessions);
  return newSession;
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
