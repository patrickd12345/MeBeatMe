export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  if (req.method === 'GET') {
    res.status(200).json({
      status: 'success',
      bests: { 'KM_3_8': 355.0 },
      bestPpi: 355.0,
      lastUpdated: Date.now()
    });
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}
