# MeBeatMe Development Guide

## 🚀 Quick Start

### Windows Development
```powershell
# Run the Windows development script
.\scripts\dev-win.ps1
```

### macOS Development
```bash
# Pull CI artifacts and set up development
./scripts/pull-artifacts-mac.sh
```

## 📁 Project Structure

```
MeBeatMe/
├── shared/                 # Kotlin Multiplatform shared module
├── androidApp/            # Android application
├── watchos/               # watchOS application
├── server/                # Ktor server
├── scripts/               # Development scripts
└── .github/workflows/     # CI/CD pipelines
```

## 🔧 Development Workflow

### 1. Windows Development (Primary)
- **Develop Swift code** in `watchos/` directory
- **Test Kotlin code** using `.\gradlew :shared:test`
- **Use placeholder XCFramework** for Swift compilation
- **Push changes** to trigger macOS CI

### 2. macOS Testing (Secondary)
- **Pull CI artifacts** using the provided script
- **Test with real XCFramework** in Xcode
- **Run on simulator/device**

## 🛠️ Available Commands

### Gradle Commands
```bash
# Test shared module
.\gradlew :shared:test

# Build Android app
.\gradlew :androidApp:build

# Build server
.\gradlew :server:build

# Run all tests
.\gradlew test
```

### Git Commands
```bash
# Commit and push changes
git add .
git commit -m "Your changes"
git push
```

## 📱 Platform-Specific Development

### Android
- **Location**: `androidApp/`
- **Build**: `.\gradlew :androidApp:build`
- **Test**: `.\gradlew :androidApp:test`

### watchOS
- **Location**: `watchos/`
- **Development**: Use placeholder XCFramework on Windows
- **Testing**: Use real XCFramework on macOS
- **CI**: Automatically builds XCFramework on macOS

### Server
- **Location**: `server/`
- **Build**: `.\gradlew :server:build`
- **Run**: `.\gradlew :server:run`

## 🔄 CI/CD Pipeline

### GitHub Actions
- **Linux**: Tests shared module, Android, server
- **macOS**: Builds XCFramework for iOS/watchOS
- **Artifacts**: Downloads real frameworks for macOS development

### Workflow
1. **Push to GitHub** → Triggers CI
2. **Linux runner** → Tests Kotlin/Android code
3. **macOS runner** → Builds XCFramework
4. **Download artifacts** → Use on macOS

## 🐛 Troubleshooting

### XCFramework Issues
- **Error**: "no binary artifact"
- **Solution**: Use placeholder XCFramework for Windows development
- **Real fix**: Download CI artifacts on macOS

### Build Issues
- **iOS targets disabled on Windows**: Expected behavior
- **Use CI**: macOS runners build iOS/watchOS targets
- **Placeholder**: Satisfies Swift Package Manager requirements

### CI Issues
- **Check Actions tab**: https://github.com/patrickd12345/MeBeatMe/actions
- **Download artifacts**: Use `./scripts/pull-artifacts-mac.sh`
- **Verify framework**: Check XCFramework structure

## 📚 Key Files

### Configuration
- `shared/build.gradle.kts` - KMP configuration
- `watchos/Package.swift` - Swift Package Manager
- `.github/workflows/ci-pipeline.yml` - CI configuration

### Scripts
- `scripts/dev-win.ps1` - Windows development setup
- `scripts/pull-artifacts-mac.sh` - macOS artifact download

### Documentation
- `watchos/README_watchOS.md` - watchOS app documentation
- `watchos/WINDOWS_DEVELOPMENT_WORKAROUND.md` - Windows workaround guide

## 🎯 Best Practices

### Development
1. **Develop on Windows** - Use placeholder framework
2. **Test on macOS** - Use real framework from CI
3. **Push frequently** - Trigger CI for real builds
4. **Use scripts** - Automate common tasks

### Code Quality
1. **Run tests** - `.\gradlew :shared:test`
2. **Check CI** - Monitor GitHub Actions
3. **Verify frameworks** - Ensure proper structure
4. **Document changes** - Clear commit messages

## 🔗 Useful Links

- **GitHub Actions**: https://github.com/patrickd12345/MeBeatMe/actions
- **Repository**: https://github.com/patrickd12345/MeBeatMe
- **Kotlin Multiplatform**: https://kotlinlang.org/docs/multiplatform.html
- **Swift Package Manager**: https://swift.org/package-manager/
