#!/usr/bin/env node

const { spawn } = require('child_process');
const path = require('path');

// Set up signal handlers before spawning the server
process.on('SIGINT', () => {
  console.log('\nReceived SIGINT. Shutting down gracefully...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\nReceived SIGTERM. Shutting down gracefully...');
  process.exit(0);
});

// Spawn the test server with proper signal handling
const serverProcess = spawn('node', ['test-server.js'], {
  stdio: 'inherit',
  detached: false,
  shell: false
});

// Handle server process termination
serverProcess.on('close', (code) => {
  console.log(`Test server exited with code ${code}`);
  process.exit(code);
});

serverProcess.on('error', (err) => {
  console.error('Failed to start test server:', err);
  process.exit(1);
});

// Forward signals to the server process
process.on('SIGINT', () => {
  console.log('\nForwarding SIGINT to test server...');
  serverProcess.kill('SIGINT');
});

process.on('SIGTERM', () => {
  console.log('\nForwarding SIGTERM to test server...');
  serverProcess.kill('SIGTERM');
});


