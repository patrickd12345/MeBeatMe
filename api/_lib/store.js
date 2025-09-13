// Simple durable store adapter. Prefers Supabase REST if configured,
// falls back to in-memory store (via dataStore.js) otherwise.

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
// Temporarily disable Supabase to force fallback to in-memory store
const SUPABASE_ENABLED = false; // Boolean(SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY);

function supabaseHeaders() {
  return {
    'Content-Type': 'application/json',
    'apikey': SUPABASE_SERVICE_ROLE_KEY,
    'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    'Prefer': 'return=representation'
  };
}

// rows are expected in durable shape:
// { id, activity_id, source, name, distance, duration, created_at, ppi, best_ppi }
export async function addSessions(rows = []) {
  if (!rows || rows.length === 0) return 0;

  if (SUPABASE_ENABLED) {
    const url = `${SUPABASE_URL}/rest/v1/sessions?on_conflict=activity_id`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { ...supabaseHeaders(), 'Prefer': 'resolution=merge-duplicates' },
      body: JSON.stringify(rows)
    });
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`Supabase upsert failed: ${res.status} ${text}`);
    }
    return rows.length;
  }

  // Fallback to in-memory store
  const { addSession } = await import('../dataStore.js');
  for (const r of rows) {
    await addSession({
      distance: r.distance,
      duration: r.duration,
      ppi: r.ppi,
      createdAt: r.created_at ? Date.parse(r.created_at) : Date.now(),
      name: r.name,
      source: r.source,
      activityId: r.activity_id
    });
  }
  return rows.length;
}

export async function listSessions(limit = 100) {
  if (SUPABASE_ENABLED) {
    try {
      const url = `${SUPABASE_URL}/rest/v1/sessions?select=*&order=created_at.desc&limit=${limit}`;
      const res = await fetch(url, { headers: supabaseHeaders() });
      if (!res.ok) {
        const text = await res.text().catch(() => '');
        console.error(`Supabase select failed: ${res.status} ${text}`);
        // Fall through to fallback
      } else {
        const rows = await res.json();
        return Array.isArray(rows) ? rows : [];
      }
    } catch (error) {
      console.error('Supabase error, falling back to in-memory store:', error.message);
      // Fall through to fallback
    }
  }

  // Fallback to in-memory store
  try {
    const { getWorkoutData } = await import('../dataStore.js');
    const data = await getWorkoutData();
    return (data.sessions || []).map(s => ({
      id: s.id,
      activity_id: s.activityId || undefined,
      source: s.source || 'fallback',
      name: s.name || s.id,
      distance: s.distance,
      duration: s.duration,
      created_at: new Date(s.createdAt || Date.now()).toISOString(),
      ppi: s.ppi,
      best_ppi: s.ppi
    }));
  } catch (error) {
    console.error('Fallback store error:', error.message);
    // Return empty array as last resort
    return [];
  }
}

export function isSupabaseEnabled() {
  return SUPABASE_ENABLED;
}



