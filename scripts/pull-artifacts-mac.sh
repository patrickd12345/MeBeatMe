#!/usr/bin/env bash
# macOS script to pull CI artifacts and set up watchOS development
# Run this on your Mac after CI has built the XCFramework

set -euo pipefail

echo "🍎 MeBeatMe macOS Development Script"
echo "===================================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) not found. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

# Check if we're authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub. Please run:"
    echo "   gh auth login"
    exit 1
fi

# Get the latest CI run
echo "📥 Fetching latest CI artifacts..."
RUN_ID=$(gh run list --repo $(gh repo view --json owner,name -q '.owner.login + "/" + .name') -w CI -L 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
    echo "❌ Error: No CI runs found. Make sure you've pushed to trigger CI."
    exit 1
fi

echo "📦 Downloading Shared.xcframework from run $RUN_ID..."

# Create frameworks directory if it doesn't exist
mkdir -p watchos/Frameworks

# Download the XCFramework artifact
gh run download $RUN_ID --repo $(gh repo view --json owner,name -q '.owner.login + "/" + .name') --name Shared.xcframework -D watchos/Frameworks

if [ $? -eq 0 ]; then
    echo "✅ Successfully downloaded Shared.xcframework!"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Open Xcode project: xed watchos/MeBeatMe.xcodeproj"
    echo "2. Select Watch Simulator (e.g., Apple Watch Series 9)"
    echo "3. Build and run the app"
    echo "4. Test with sample files in TestAssets/"
    echo ""
    echo "📱 To run on device:"
    echo "1. Set up your Apple Developer account in Xcode"
    echo "2. Configure signing & provisioning"
    echo "3. Select your Apple Watch as the destination"
else
    echo "❌ Failed to download artifacts"
    exit 1
fi
