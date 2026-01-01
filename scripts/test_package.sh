#!/bin/bash

# Manim iOS Package Testing Workflow
# This script guides you through testing the Manim iOS package

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     Manim iOS Package - Complete Testing Workflow         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Verify Build
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Verify All Libraries Are Built"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./scripts/verify_build.sh

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build verification failed!"
    echo "Please run the build scripts first:"
    echo "  ./scripts/build_all_ios.sh"
    exit 1
fi

echo ""
read -p "Continue to bundling? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Step 2: Bundle Package
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Create Distribution Bundle"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./scripts/bundle.sh

echo ""
read -p "Continue to test app creation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# Step 3: Create Test App
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Create Test Application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./scripts/create_test_app.sh

echo ""
read -p "Run the test app now? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "You can run it later with:"
    echo "  cd ~/Desktop/ManimTestApp"
    echo "  swift run"
    exit 0
fi

# Step 4: Run Test App
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Running Test Application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd ~/Desktop/ManimTestApp

echo "Building test app..."
swift build

echo ""
echo "Running tests..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
swift run

# Step 5: Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Library verification: Passed"
echo "✅ Package bundling: Complete"
echo "✅ Test app creation: Complete"
echo "✅ Command-line tests: Passed"
echo ""
echo "Next steps:"
echo "  1. Test in Xcode with real iOS device:"
echo "     - Create new iOS app in Xcode"
echo "     - Add local package: /Users/euler/manim"
echo "     - Use SwiftUI example from BUNDLING.md"
echo ""
echo "  2. Test video rendering:"
echo "     - Run on iOS Simulator or device"
echo "     - Render an animation"
echo "     - Verify MP4 output"
echo ""
echo "  3. Distribute package:"
echo "     - Upload to GitHub"
echo "     - Tag release: git tag v1.0.0"
echo "     - Share bundle: dist/ManimIOS-1.0.0.tar.gz"
echo ""
echo "Documentation:"
echo "  - README.md - Overview and quick start"
echo "  - TESTING.md - Comprehensive testing guide"
echo "  - BUNDLING.md - Distribution instructions"
echo ""
