# MeBeatMe Automatic Deployment Setup Script (Windows)
# This script helps you set up automatic build and deployment

Write-Host "🚀 MeBeatMe Automatic Deployment Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Error: Not in MeBeatMe root directory" -ForegroundColor Red
    Write-Host "Please run this script from the project root" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found MeBeatMe project" -ForegroundColor Green
Write-Host ""

# Check if Vercel CLI is installed
try {
    $vercelVersion = vercel --version 2>&1
    Write-Host "✅ Vercel CLI already installed: $vercelVersion" -ForegroundColor Green
} catch {
    Write-Host "📦 Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel@latest
    Write-Host "✅ Vercel CLI installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔧 Setting up Vercel project..." -ForegroundColor Yellow

# Check if already linked
if (Test-Path ".vercel/project.json") {
    Write-Host "✅ Project already linked to Vercel" -ForegroundColor Green
} else {
    Write-Host "🔗 Linking project to Vercel..." -ForegroundColor Yellow
    vercel link
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host ""

# Get GitHub repository info
$gitRemote = git config --get remote.origin.url
if ($gitRemote) {
    $repoInfo = $gitRemote -replace ".*github.com[:/]([^/]*)/([^.]*).*", '$1/$2'
    Write-Host "1. 🔑 Add GitHub Secrets:" -ForegroundColor White
    Write-Host "   Go to: https://github.com/$repoInfo/settings/secrets/actions" -ForegroundColor Blue
} else {
    Write-Host "1. 🔑 Add GitHub Secrets:" -ForegroundColor White
    Write-Host "   Go to: Your GitHub repository → Settings → Secrets and variables → Actions" -ForegroundColor Blue
}

Write-Host ""
Write-Host "2. 📝 Add these secrets:" -ForegroundColor White
Write-Host "   - VERCEL_TOKEN: Get from vercel.com → Account → Tokens" -ForegroundColor Blue
Write-Host "   - VERCEL_PROJECT_ID: Get from vercel.com → Project → Settings" -ForegroundColor Blue
Write-Host "   - VERCEL_ORG_ID: Get from vercel.com → Team → Settings" -ForegroundColor Blue
Write-Host ""
Write-Host "3. 🧪 Test the setup:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Blue
Write-Host "   git commit -m 'Test automatic deployment'" -ForegroundColor Blue
Write-Host "   git push" -ForegroundColor Blue
Write-Host ""

if ($gitRemote) {
    Write-Host "4. 📊 Monitor deployment:" -ForegroundColor White
    Write-Host "   - GitHub Actions: https://github.com/$repoInfo/actions" -ForegroundColor Blue
} else {
    Write-Host "4. 📊 Monitor deployment:" -ForegroundColor White
    Write-Host "   - GitHub Actions: Your repository → Actions tab" -ForegroundColor Blue
}
Write-Host "   - Vercel Dashboard: https://vercel.com/dashboard" -ForegroundColor Blue
Write-Host ""

# Get current project info
if (Test-Path ".vercel/project.json") {
    $projectJson = Get-Content ".vercel/project.json" | ConvertFrom-Json
    $projectId = $projectJson.projectId
    $orgId = $projectJson.orgId
    
    Write-Host "📋 Your Project Details:" -ForegroundColor Cyan
    Write-Host "=======================" -ForegroundColor Cyan
    Write-Host "Project ID: $projectId" -ForegroundColor Green
    Write-Host "Org ID: $orgId" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Copy these values to your GitHub secrets!" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Setup complete! Follow the steps above to enable automatic deployment." -ForegroundColor Green
Write-Host ""
Write-Host "📚 For detailed instructions, see: AUTOMATIC_DEPLOYMENT_SETUP.md" -ForegroundColor Blue
