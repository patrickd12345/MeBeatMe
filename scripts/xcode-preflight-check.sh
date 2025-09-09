#!/bin/bash
# Xcode Preflight Check Script
# Add this as a Run Script Phase in Xcode before Compile Sources

set -e

# Set SRCROOT if not defined (for command line testing)
if [ -z "$SRCROOT" ]; then
    SRCROOT="$(pwd)"
fi

FRAMEWORK_DIR="${SRCROOT}/watchos/Frameworks"
XCFRAMEWORK_DIR="${FRAMEWORK_DIR}/Shared.xcframework"

echo "🔍 Checking for Shared.xcframework..."

if [ ! -d "$XCFRAMEWORK_DIR" ]; then
    echo "❌ ERROR: Shared.xcframework missing!"
    echo "📁 Expected location: $XCFRAMEWORK_DIR"
    echo ""
    echo "💡 To fix this:"
    echo "   1. Run: ./scripts/pull-artifacts-mac.sh"
    echo "   2. Or manually download from GitHub Actions"
    echo ""
    echo "🔗 Check CI status: gh run list --workflow 'KMP Artifacts'"
    exit 1
fi

# Check if it's a proper XCFramework structure
if [ ! -f "${XCFRAMEWORK_DIR}/Info.plist" ]; then
    echo "❌ ERROR: Invalid XCFramework structure!"
    echo "📁 Missing Info.plist in: $XCFRAMEWORK_DIR"
    exit 1
fi

# Check for required architectures
ARCH_COUNT=$(find "$XCFRAMEWORK_DIR" -name "*.framework" | wc -l)
if [ "$ARCH_COUNT" -lt 2 ]; then
    echo "⚠️  WARNING: XCFramework may be incomplete (only $ARCH_COUNT architectures found)"
    echo "📁 Expected: ios-arm64 + ios-arm64-simulator"
fi

echo "✅ Shared.xcframework found and looks good!"
echo "📊 Architectures: $ARCH_COUNT"
echo "🎯 Ready to build!"
