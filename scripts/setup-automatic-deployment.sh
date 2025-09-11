#!/bin/bash
# MeBeatMe Automatic Deployment Setup Script
# This script helps you set up automatic build and deployment

echo "🚀 MeBeatMe Automatic Deployment Setup"
echo "======================================"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Not in MeBeatMe root directory"
    echo "Please run this script from the project root"
    exit 1
fi

echo "✅ Found MeBeatMe project"
echo ""

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel@latest
    echo "✅ Vercel CLI installed"
else
    echo "✅ Vercel CLI already installed"
fi

echo ""
echo "🔧 Setting up Vercel project..."

# Check if already linked
if [ -f ".vercel/project.json" ]; then
    echo "✅ Project already linked to Vercel"
else
    echo "🔗 Linking project to Vercel..."
    vercel link
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. 🔑 Add GitHub Secrets:"
echo "   Go to: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1\/\2/')/settings/secrets/actions"
echo ""
echo "2. 📝 Add these secrets:"
echo "   - VERCEL_TOKEN: Get from vercel.com → Account → Tokens"
echo "   - VERCEL_PROJECT_ID: Get from vercel.com → Project → Settings"
echo "   - VERCEL_ORG_ID: Get from vercel.com → Team → Settings"
echo ""
echo "3. 🧪 Test the setup:"
echo "   git add ."
echo "   git commit -m 'Test automatic deployment'"
echo "   git push"
echo ""
echo "4. 📊 Monitor deployment:"
echo "   - GitHub Actions: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1\/\2/')/actions"
echo "   - Vercel Dashboard: https://vercel.com/dashboard"
echo ""

# Get current project info
if [ -f ".vercel/project.json" ]; then
    PROJECT_ID=$(cat .vercel/project.json | grep -o '"projectId":"[^"]*"' | cut -d'"' -f4)
    ORG_ID=$(cat .vercel/project.json | grep -o '"orgId":"[^"]*"' | cut -d'"' -f4)
    
    echo "📋 Your Project Details:"
    echo "======================="
    echo "Project ID: $PROJECT_ID"
    echo "Org ID: $ORG_ID"
    echo ""
    echo "💡 Copy these values to your GitHub secrets!"
fi

echo "🎉 Setup complete! Follow the steps above to enable automatic deployment."
echo ""
echo "📚 For detailed instructions, see: AUTOMATIC_DEPLOYMENT_SETUP.md"
