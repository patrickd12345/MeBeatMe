# Windows Development Script
# Run this from the repo root on Windows

Write-Host "🏃‍♂️ MeBeatMe Windows Development Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if we're in the right directory
if (-not (Test-Path "gradlew.bat")) {
    Write-Host "❌ Error: gradlew.bat not found. Please run this script from the repo root." -ForegroundColor Red
    exit 1
}

Write-Host "📦 Building and testing shared KMP code..." -ForegroundColor Yellow
.\gradlew :shared:clean :shared:test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Shared tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Shared tests passed!" -ForegroundColor Green

Write-Host "🧪 Running server tests..." -ForegroundColor Yellow
.\gradlew :server:test

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Server tests failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Server tests passed!" -ForegroundColor Green

Write-Host "🌐 Building web app..." -ForegroundColor Yellow
.\gradlew :web:build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Web build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Web build successful!" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 All Windows builds completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Commit your changes: git add . && git commit -m 'Your message'" -ForegroundColor White
Write-Host "2. Push to trigger macOS CI: git push" -ForegroundColor White
Write-Host "3. Check GitHub Actions for watchOS build artifacts" -ForegroundColor White
Write-Host ""
Write-Host "Optional - Start local server:" -ForegroundColor Cyan
Write-Host ".\gradlew :server:run" -ForegroundColor White
Write-Host ""
Write-Host "Optional - Start web dev server:" -ForegroundColor Cyan
Write-Host ".\gradlew :web:browserDevelopmentRun" -ForegroundColor White
