const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use(express.static('.'));

// Mock data for testing
const mockWorkoutData = {
  sessions: [
    {
      id: 'test_1',
      name: 'Morning Run',
      distance: 5000,
      duration: 1800,
      ppi: 250,
      createdAt: Date.now()
    },
    {
      id: 'test_2',
      name: 'Evening Jog',
      distance: 3000,
      duration: 1200,
      ppi: 200,
      createdAt: Date.now()
    }
  ],
  bestPpi: 250
};

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'success', message: 'API is healthy' });
});

app.get('/api/sync/sessions', (req, res) => {
  const transformedSessions = mockWorkoutData.sessions.map(session => ({
    id: session.id,
    filename: session.name || session.id,
    distance: session.distance,
    duration: session.duration,
    ppi: session.ppi,
    createdAt: session.createdAt
  }));

  res.json({
    status: 'success',
    sessions: transformedSessions,
    count: transformedSessions.length,
    bestPpi: mockWorkoutData.bestPpi
  });
});

app.get('/api/sync/bests', (req, res) => {
  const bests = {};
  mockWorkoutData.sessions.forEach(session => {
    const distanceKm = session.distance / 1000;
    let distanceKey;
    if (distanceKm <= 3) distanceKey = '1-3K';
    else if (distanceKm <= 8) distanceKey = '3-8K';
    else if (distanceKm <= 15) distanceKey = '8-15K';
    else if (distanceKm <= 25) distanceKey = '15-25K';
    else distanceKey = '25K+';
    
    if (!bests[distanceKey] || session.ppi > bests[distanceKey]) {
      bests[distanceKey] = session.ppi;
    }
  });

  res.json({
    status: 'success',
    bests: bests,
    bestPpi: mockWorkoutData.bestPpi,
    lastUpdated: Date.now()
  });
});

app.post('/api/strava/token', (req, res) => {
  res.json({ 
    status: 'error', 
    message: 'Mock endpoint - Strava integration not configured for testing' 
  });
});

app.post('/api/strava/import', (req, res) => {
  res.json({ 
    status: 'error', 
    message: 'Mock endpoint - Strava integration not configured for testing' 
  });
});

// Serve dashboard.html as root
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'dashboard.html'));
});

app.listen(PORT, () => {
  console.log(`Test server running on http://localhost:${PORT}`);
  console.log('Dashboard available at: http://localhost:3000');
  console.log('API endpoints available at: http://localhost:3000/api/*');
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\nReceived SIGINT. Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\nReceived SIGTERM. Shutting down gracefully...');
  process.exit(0);
});

// Prevent process from hanging on Ctrl+C
process.on('SIGUSR1', () => {
  console.log('\nReceived SIGUSR1. Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGUSR2', () => {
  console.log('\nReceived SIGUSR2. Shutting down gracefully...');
  process.exit(0);
});
