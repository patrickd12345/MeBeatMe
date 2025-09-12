// Strava OAuth callback endpoint
// - Exchanges ?code for tokens
// - Sets HttpOnly cookies with access/refresh tokens
// - Notifies the opener window and closes the popup

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const url = new URL(req.url, 'http://localhost');
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state') || '';

    if (!code) {
      res.status(400).send(renderResultPage('error', 'Missing authorization code', state));
      return;
    }

    const clientId = process.env.STRAVA_CLIENT_ID || '157217';
    const clientSecret = process.env.STRAVA_CLIENT_SECRET;

    if (!clientSecret || clientSecret === 'YOUR_STRAVA_CLIENT_SECRET') {
      res.status(500).send(renderResultPage('error', 'Server missing STRAVA_CLIENT_SECRET', state));
      return;
    }

    const tokenResponse = await fetch('https://www.strava.com/oauth/token', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        client_id: String(clientId),
        client_secret: String(clientSecret),
        code: code,
        grant_type: 'authorization_code'
      })
    });

    if (!tokenResponse.ok) {
      const text = await tokenResponse.text();
      res.status(400).send(renderResultPage('error', `Strava token exchange failed (HTTP ${tokenResponse.status})`, state));
      return;
    }

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;
    const refreshToken = tokenData.refresh_token;
    const expiresAt = tokenData.expires_at ? Number(tokenData.expires_at) : 0;

    if (!accessToken) {
      res.status(400).send(renderResultPage('error', 'No access_token received from Strava', state));
      return;
    }

    const maxAge = expiresAt > 0 ? Math.max(0, expiresAt - Math.floor(Date.now() / 1000)) : 3600;
    const secure = 'Secure;';
    const common = `Path=/; ${secure} HttpOnly; SameSite=Lax; Max-Age=${maxAge}`;

    res.setHeader('Set-Cookie', [
      `strava_access_token=${encodeURIComponent(accessToken)}; ${common}`,
      refreshToken ? `strava_refresh_token=${encodeURIComponent(refreshToken)}; ${common}` : `strava_refresh_token=; Path=/; ${secure} HttpOnly; SameSite=Lax; Max-Age=0`,
      expiresAt ? `strava_expires_at=${expiresAt}; ${common}` : `strava_expires_at=; Path=/; ${secure} HttpOnly; SameSite=Lax; Max-Age=0`
    ]);

    res.status(200).send(renderResultPage('success', 'Strava connected. You can close this window.', state, accessToken));
  } catch (error) {
    res.status(500).send(renderResultPage('error', 'Unexpected server error', ''));
  }
}

function renderResultPage(status, message, state, accessToken = null) {
  const payload = JSON.stringify({ 
    type: status === 'success' ? 'strava-auth-success' : 'strava-auth-error', 
    state, 
    message,
    access_token: accessToken
  });
  return `<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Strava Auth</title></head>
<body style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Inter, Roboto, sans-serif; padding:24px;">
  <p>${escapeHtml(message)}</p>
  <script>
    try {
      if (window.opener) {
        console.log('Sending message to opener:', ${payload});
        window.opener.postMessage(${payload}, '*');
      }
      setTimeout(function(){ window.close(); }, 1000);
    } catch (e) { 
      console.error('Error sending message:', e);
      setTimeout(function(){ window.close(); }, 1000); 
    }
  </script>
</body></html>`;
}

function escapeHtml(str) {
  return String(str).replace(/[&<>"']/g, function(s){
    return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'}[s]);
  });
}




