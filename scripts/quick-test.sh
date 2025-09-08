#!/usr/bin/env bash
# Quick test script for Windows development
# Run this to quickly test the core KMP functionality

set -e

echo "🧪 MeBeatMe Quick Test Script"
echo "============================="

# Test shared KMP code
echo "📦 Testing shared KMP code..."
./gradlew :shared:test

# Test server endpoints
echo "🌐 Testing server..."
./gradlew :server:test

# Test web app
echo "💻 Testing web app..."
./gradlew :web:test

echo ""
echo "✅ All tests passed! Ready to commit and push."
echo ""
echo "Next: git add . && git commit -m 'Your changes' && git push"
