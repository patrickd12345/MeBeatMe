#!/usr/bin/env pwsh
# Windows development script for MeBeatMe
# Run this to set up your Windows development environment

Write-Host "🪟 MeBeatMe Windows Development Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if we're in the right directory
if (-not (Test-Path "build.gradle.kts")) {
    Write-Host "❌ Error: Not in MeBeatMe root directory" -ForegroundColor Red
    Write-Host "Please run this script from the project root" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found MeBeatMe project" -ForegroundColor Green

# Check Java installation
Write-Host "🔍 Checking Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✅ Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Java not found. Please install JDK 17" -ForegroundColor Red
    Write-Host "Download from: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

# Run shared module tests
Write-Host "🧪 Running shared module tests..." -ForegroundColor Yellow
try {
    .\gradlew :shared:test
    Write-Host "✅ Shared module tests passed" -ForegroundColor Green
} catch {
    Write-Host "❌ Shared module tests failed" -ForegroundColor Red
    Write-Host "Check the output above for details" -ForegroundColor Yellow
}

# Check placeholder XCFramework
Write-Host "🔍 Checking placeholder XCFramework..." -ForegroundColor Yellow
$frameworkPath = "watchos\Frameworks\Shared.xcframework\Info.plist"
if (Test-Path $frameworkPath) {
    Write-Host "✅ Placeholder XCFramework found" -ForegroundColor Green
    Write-Host "📱 You can now develop Swift code on Windows" -ForegroundColor Green
} else {
    Write-Host "❌ Placeholder XCFramework missing" -ForegroundColor Red
    Write-Host "Run the XCFramework fix script first" -ForegroundColor Yellow
}

# Show development workflow
Write-Host ""
Write-Host "🎯 Development Workflow:" -ForegroundColor Cyan
Write-Host "1. Develop Swift code in watchos/ directory" -ForegroundColor White
Write-Host "2. Test compilation (placeholder framework satisfies SPM)" -ForegroundColor White
Write-Host "3. Push changes: git add .; git commit -m 'Your changes'; git push" -ForegroundColor White
Write-Host "4. CI will build real XCFramework on macOS" -ForegroundColor White
Write-Host "5. Download artifacts on Mac: ./scripts/pull-artifacts-mac.sh" -ForegroundColor White
Write-Host "6. Test on macOS with real framework" -ForegroundColor White

Write-Host ""
Write-Host "🔗 Useful Commands:" -ForegroundColor Cyan
Write-Host "• Run tests: .\gradlew :shared:test" -ForegroundColor White
Write-Host "• Build Android: .\gradlew :androidApp:build" -ForegroundColor White
Write-Host "• Build server: .\gradlew :server:build" -ForegroundColor White
Write-Host "• Check CI: https://github.com/patrickd12345/MeBeatMe/actions" -ForegroundColor White

Write-Host ""
Write-Host "✅ Windows development environment ready!" -ForegroundColor Green