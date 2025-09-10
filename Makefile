# MeBeatMe Development Makefile
# Quick commands for the happy path

.PHONY: pull xcode run clean-caches help

# Pull latest CI artifacts
pull:
	@echo "📥 Pulling latest CI artifacts..."
	./scripts/pull-artifacts-mac.sh

# Open Xcode project
xcode:
	@echo "🍎 Opening Xcode..."
	open watchos/MeBeatMe.xcodeproj

# Run on simulator (boot + open Xcode)
run:
	@echo "⌚ Booting Apple Watch Series 9 simulator..."
	xcrun simctl boot 'Apple Watch Series 9' || true
	@echo "🍎 Opening Xcode..."
	open watchos/MeBeatMe.xcodeproj

# Clean Xcode caches (use sparingly!)
clean-caches:
	@echo "🧹 Cleaning Xcode caches..."
	rm -rf ~/Library/Developer/Xcode/DerivedData
	rm -rf ~/Library/Caches/org.swift.swiftpm
	@echo "✅ Caches cleaned!"

# Fix Xcode CLI tools
fix-xcode:
	@echo "🔧 Fixing Xcode CLI tools..."
	sudo xcode-select -s /Applications/Xcode.app
	sudo xcodebuild -license accept
	@echo "✅ Xcode CLI tools fixed!"

# Check CI status
ci-status:
	@echo "🔍 Checking CI status..."
	gh run list --workflow "KMP Artifacts" --limit 3

# Full setup (pull + open)
setup: pull xcode
	@echo "🎯 Ready to build!"

# Help
help:
	@echo "MeBeatMe Development Commands:"
	@echo "  make pull        - Pull latest CI artifacts"
	@echo "  make xcode       - Open Xcode project"
	@echo "  make run         - Boot simulator + open Xcode"
	@echo "  make setup       - Pull artifacts + open Xcode"
	@echo "  make clean-caches- Clean Xcode caches"
	@echo "  make fix-xcode   - Fix Xcode CLI tools"
	@echo "  make ci-status   - Check CI status"
	@echo "  make help        - Show this help"
