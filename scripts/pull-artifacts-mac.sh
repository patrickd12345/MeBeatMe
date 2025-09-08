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

# Get repository info
REPO=$(gh repo view --json owner,name -q '.owner.login + "/" + .name')
echo "📦 Repository: $REPO"

# Get the latest CI run
echo "📥 Fetching latest CI artifacts..."
RUN_ID=$(gh run list --repo $REPO -w CI -L 1 --json databaseId -q '.[0].databaseId')

if [ -z "$RUN_ID" ]; then
    echo "❌ Error: No CI runs found. Make sure you've pushed to trigger CI."
    exit 1
fi

echo "📦 Downloading Shared.xcframework from run $RUN_ID..."

# Create frameworks directory if it doesn't exist
mkdir -p watchos/Frameworks

# Download the XCFramework artifact
if gh run download $RUN_ID --repo $REPO --name Shared.xcframework -D watchos/Frameworks; then
    echo "✅ Successfully downloaded Shared.xcframework!"
    
    # Verify the framework structure
    if [ -d "watchos/Frameworks/Shared.xcframework" ]; then
        echo "🔍 Verifying XCFramework structure..."
        if [ -f "watchos/Frameworks/Shared.xcframework/Info.plist" ]; then
            echo "✅ XCFramework structure verified!"
        else
            echo "⚠️  Warning: XCFramework may be incomplete"
        fi
    fi
    
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
    echo ""
    echo "🔧 Development workflow:"
    echo "1. Make changes on Windows"
    echo "2. Push to trigger CI"
    echo "3. Run this script to get updated framework"
    echo "4. Test on macOS"
else
    echo "❌ Failed to download artifacts"
    echo "💡 Try running: gh run list --repo $REPO to see available runs"
    exit 1
fi
