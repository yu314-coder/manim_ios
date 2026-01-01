# Manim iOS Package Bundling & Distribution Guide

This guide explains how to bundle the Manim iOS package and test it in a real app.

## Table of Contents
1. [Package Structure](#package-structure)
2. [Bundling Process](#bundling-process)
3. [Testing Methods](#testing-methods)
4. [Distribution Options](#distribution-options)

---

## Package Structure

After building all libraries, your package structure should look like:

```
/Users/euler/manim/
├── Package.swift                 # Swift Package Manager manifest
├── manim/                        # Swift source code
│   ├── manim.swift
│   ├── PythonManager.swift
│   ├── ManimBridge.swift
│   ├── ManimScene.swift
│   ├── ManimObject.swift
│   ├── ManimRenderer.swift
│   └── ManimExample.swift
├── Frameworks/                   # Pre-built XCFrameworks
│   ├── zlib.xcframework
│   ├── libpng.xcframework
│   ├── FreeType.xcframework
│   ├── Pixman.xcframework
│   ├── Expat.xcframework
│   ├── FriBidi.xcframework
│   ├── HarfBuzz.xcframework
│   ├── Cairo.xcframework
│   ├── FontConfig.xcframework
│   ├── GLib.xcframework
│   └── Pango.xcframework
├── Python.xcframework/           # Python 3.14 runtime
│   ├── ios-arm64/
│   ├── ios-arm64-simulator/
│   └── ios-x86_64-simulator/
├── README.md
├── QUICKSTART.md
├── INSTALLATION.md
├── TESTING.md
└── BUNDLING.md (this file)
```

---

## Bundling Process

### Step 1: Verify All Libraries Are Built

```bash
cd /Users/euler/manim

# Run verification script
cat > verify_build.sh << 'EOF'
#!/bin/bash

echo "🔍 Verifying Manim iOS Build"
echo "=============================="

REQUIRED_FRAMEWORKS=(
    "zlib"
    "libpng"
    "FreeType"
    "Pixman"
    "Expat"
    "FriBidi"
    "HarfBuzz"
    "Cairo"
    "FontConfig"
    "GLib"
    "Pango"
)

ALL_PRESENT=true

for fw in "${REQUIRED_FRAMEWORKS[@]}"; do
    if [ -d "Frameworks/${fw}.xcframework" ]; then
        # Count slices
        slices=$(find "Frameworks/${fw}.xcframework" -name "*.a" | wc -l | xargs)
        echo "✅ ${fw}.xcframework ($slices slices)"
    else
        echo "❌ ${fw}.xcframework MISSING"
        ALL_PRESENT=false
    fi
done

# Check Python framework
if [ -d "Python.xcframework" ]; then
    echo "✅ Python.xcframework"
else
    echo "❌ Python.xcframework MISSING"
    ALL_PRESENT=false
fi

echo ""
if [ "$ALL_PRESENT" = true ]; then
    echo "✅ All frameworks present!"
    exit 0
else
    echo "❌ Some frameworks are missing"
    exit 1
fi
EOF

chmod +x verify_build.sh
./verify_build.sh
```

### Step 2: Update Package.swift

Ensure Package.swift correctly references all frameworks:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Manim",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Manim",
            targets: ["Manim"]
        ),
    ],
    dependencies: [
        // PythonKit for Swift-Python bridge
        .package(url: "https://github.com/pvieito/PythonKit.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Manim",
            dependencies: ["PythonKit"],
            path: "manim",
            linkerSettings: [
                .linkedFramework("Python"),
                .linkedLibrary("z"),
                .linkedLibrary("png"),
                .linkedLibrary("freetype"),
                .linkedLibrary("pixman-1"),
                .linkedLibrary("expat"),
                .linkedLibrary("fribidi"),
                .linkedLibrary("harfbuzz"),
                .linkedLibrary("cairo"),
                .linkedLibrary("fontconfig"),
                .linkedLibrary("glib-2.0"),
                .linkedLibrary("pango-1.0"),
            ]
        )
    ]
)
```

### Step 3: Create Distribution Bundle

```bash
cd /Users/euler/manim

# Create bundle script
cat > bundle.sh << 'EOF'
#!/bin/bash

BUNDLE_NAME="ManimIOS"
BUNDLE_VERSION="1.0.0"
OUTPUT_DIR="dist"

echo "📦 Bundling Manim iOS v${BUNDLE_VERSION}"
echo "======================================="

# Clean previous bundle
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/$BUNDLE_NAME"

# Copy frameworks
echo "Copying XCFrameworks..."
cp -R Frameworks "$OUTPUT_DIR/$BUNDLE_NAME/"
cp -R Python.xcframework "$OUTPUT_DIR/$BUNDLE_NAME/"

# Copy Swift sources
echo "Copying Swift sources..."
cp -R manim "$OUTPUT_DIR/$BUNDLE_NAME/"

# Copy package manifest
cp Package.swift "$OUTPUT_DIR/$BUNDLE_NAME/"

# Copy documentation
echo "Copying documentation..."
cp README.md "$OUTPUT_DIR/$BUNDLE_NAME/"
cp QUICKSTART.md "$OUTPUT_DIR/$BUNDLE_NAME/"
cp INSTALLATION.md "$OUTPUT_DIR/$BUNDLE_NAME/"
cp TESTING.md "$OUTPUT_DIR/$BUNDLE_NAME/"

# Create archive
echo "Creating archive..."
cd "$OUTPUT_DIR"
tar -czf "${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz" "$BUNDLE_NAME"
cd ..

echo ""
echo "✅ Bundle created: $OUTPUT_DIR/${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz"

# Calculate size
SIZE=$(du -h "$OUTPUT_DIR/${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz" | cut -f1)
echo "📊 Bundle size: $SIZE"
EOF

chmod +x bundle.sh
./bundle.sh
```

### Step 4: Create Binary XCFramework (Optional)

For better distribution, you can create a single binary XCFramework:

```bash
# Create combined framework
cat > create_binary_framework.sh << 'EOF'
#!/bin/bash

FRAMEWORK_NAME="Manim"
OUTPUT="build/ManimFramework"

# Build for device
xcodebuild archive \
    -project Manim.xcodeproj \
    -scheme Manim \
    -destination "generic/platform=iOS" \
    -archivePath "$OUTPUT/ios.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for simulator
xcodebuild archive \
    -project Manim.xcodeproj \
    -scheme Manim \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$OUTPUT/ios_sim.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
xcodebuild -create-xcframework \
    -framework "$OUTPUT/ios.xcarchive/Products/Library/Frameworks/Manim.framework" \
    -framework "$OUTPUT/ios_sim.xcarchive/Products/Library/Frameworks/Manim.framework" \
    -output "$OUTPUT/Manim.xcframework"

echo "✅ Binary framework created: $OUTPUT/Manim.xcframework"
EOF

chmod +x create_binary_framework.sh
```

---

## Testing Methods

### Method 1: Local Swift Package (Fastest for Development)

Create a test app that uses the local package:

```bash
# Create test app directory
mkdir -p ~/ManimTestApp
cd ~/ManimTestApp

# Create Xcode project (use Xcode GUI or xcodegen)
# File > New > Project > iOS > App
# Name: ManimTestApp
```

**Add local package to Xcode project:**

1. Open Xcode project
2. File → Add Package Dependencies
3. Click "Add Local..."
4. Navigate to `/Users/euler/manim`
5. Add package

**Alternatively, use Package.swift for SPM:**

```swift
// Package.swift for test app
let package = Package(
    name: "ManimTestApp",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(path: "/Users/euler/manim")
    ],
    targets: [
        .target(
            name: "ManimTestApp",
            dependencies: ["Manim"]
        )
    ]
)
```

### Method 2: Test App with SwiftUI

Create a minimal test app:

```bash
cd ~/ManimTestApp

# Create ContentView.swift
cat > ContentView.swift << 'EOF'
import SwiftUI
import Manim
import AVKit

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var isRendering = false
    @State private var status = "Ready"
    @State private var error: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Manim iOS Test")
                .font(.largeTitle)
                .bold()

            Text(status)
                .foregroundColor(isRendering ? .orange : .primary)

            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 400)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 400)
                    .overlay(
                        Text("Video will appear here")
                            .foregroundColor(.secondary)
                    )
            }

            Button(action: testSimpleAnimation) {
                HStack {
                    if isRendering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "play.circle.fill")
                    }
                    Text(isRendering ? "Rendering..." : "Render Animation")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isRendering)

            if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
    }

    func testSimpleAnimation() {
        isRendering = true
        status = "Initializing Manim..."
        error = nil
        videoURL = nil

        Task {
            do {
                // Initialize
                let manim = Manim.shared
                try manim.initialize()

                await MainActor.run {
                    status = "Creating scene..."
                }

                // Create scene
                let scene = try manim.createScene()

                await MainActor.run {
                    status = "Adding circle..."
                }

                // Add circle
                let circle = scene.createCircle(radius: 1.0, color: "BLUE")
                try scene.play(circle.create())

                await MainActor.run {
                    status = "Rendering video..."
                }

                // Render
                let output = FileManager.default.temporaryDirectory
                    .appendingPathComponent("test_\(Date().timeIntervalSince1970).mp4")

                try await scene.render(to: output)

                await MainActor.run {
                    self.videoURL = output
                    self.status = "✅ Complete!"
                    self.isRendering = false
                }

            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.status = "❌ Failed"
                    self.isRendering = false
                }
            }
        }
    }
}
EOF
```

### Method 3: Unit Tests

Create unit tests for the package:

```bash
cd /Users/euler/manim

# Create Tests directory
mkdir -p Tests/ManimTests

cat > Tests/ManimTests/ManimTests.swift << 'EOF'
import XCTest
@testable import Manim

final class ManimTests: XCTestCase {

    func testInitialization() throws {
        let manim = Manim.shared
        XCTAssertNoThrow(try manim.initialize())
    }

    func testSceneCreation() throws {
        let manim = Manim.shared
        try manim.initialize()

        let scene = try manim.createScene()
        XCTAssertNotNil(scene)
    }

    func testCircleCreation() throws {
        let manim = Manim.shared
        try manim.initialize()

        let scene = try manim.createScene()
        let circle = scene.createCircle(radius: 1.0, color: "RED")

        XCTAssertNotNil(circle)
    }

    func testVersion() throws {
        let manim = Manim.shared
        try manim.initialize()

        let version = manim.version
        XCTAssertNotNil(version)
        print("Manim version: \(version ?? "unknown")")
    }
}
EOF

# Run tests
swift test
```

### Method 4: Command Line Test

Quick test from command line:

```bash
cd /Users/euler/manim

cat > test_cli.swift << 'EOF'
import Foundation
import Manim

print("🧪 Testing Manim iOS from CLI")
print("==============================\n")

do {
    // Test 1: Initialize
    print("Test 1: Initializing Manim...")
    let manim = Manim.shared
    try manim.initialize()
    print("✅ Initialized\n")

    // Test 2: Version
    print("Test 2: Getting version...")
    if let version = manim.version {
        print("✅ Version: \(version)\n")
    }

    // Test 3: Create scene
    print("Test 3: Creating scene...")
    let scene = try manim.createScene()
    print("✅ Scene created\n")

    // Test 4: Create objects
    print("Test 4: Creating objects...")
    let circle = scene.createCircle(radius: 1.0, color: "BLUE")
    let text = scene.createText("Hello!")
    print("✅ Objects created\n")

    print("✅ All CLI tests passed!")

} catch {
    print("❌ Error: \(error)")
    exit(1)
}
EOF

# Compile and run
swiftc -I manim -L Frameworks test_cli.swift -o test_cli
./test_cli
```

---

## Distribution Options

### Option 1: GitHub Repository

**Best for open source:**

```bash
cd /Users/euler/manim

# Initialize git if not already
git init
git add .
git commit -m "Initial commit: Manim iOS package"

# Create GitHub repo and push
git remote add origin https://github.com/yourusername/manim-ios.git
git branch -M main
git push -u origin main

# Tag release
git tag v1.0.0
git push --tags
```

**Users can then install via SPM:**

```swift
// In their Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/manim-ios.git", from: "1.0.0")
]
```

### Option 2: Binary XCFramework (CocoaPods/Carthage)

**For binary distribution:**

1. Create binary XCFramework (see Step 4 above)
2. Upload to GitHub releases
3. Create podspec:

```ruby
# Manim.podspec
Pod::Spec.new do |s|
  s.name             = 'Manim'
  s.version          = '1.0.0'
  s.summary          = 'Manim animation library for iOS'
  s.homepage         = 'https://github.com/yourusername/manim-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your@email.com' }
  s.source           = {
    :http => 'https://github.com/yourusername/manim-ios/releases/download/v1.0.0/Manim.xcframework.zip'
  }

  s.ios.deployment_target = '13.0'
  s.vendored_frameworks = 'Manim.xcframework'

  s.dependency 'PythonKit'
end
```

### Option 3: Private Package (For Internal Use)

**Host on private server:**

```bash
# Create archive
./bundle.sh

# Upload to your server
scp dist/ManimIOS-1.0.0.tar.gz user@yourserver.com:/path/to/packages/

# Users download and extract
curl -L https://yourserver.com/packages/ManimIOS-1.0.0.tar.gz | tar xz
```

### Option 4: Local Development Package

**For development/testing:**

```swift
// In test app's Package.swift
dependencies: [
    .package(path: "/Users/euler/manim")
]

// Or in Xcode: File > Add Package Dependencies > Add Local
```

---

## Quick Test Workflow

**After all libraries are built, run this workflow:**

```bash
cd /Users/euler/manim

# 1. Verify build
./verify_build.sh

# 2. Run unit tests
swift test

# 3. Create bundle
./bundle.sh

# 4. Test in example app
# (Use Method 2 above to create SwiftUI test app)

# 5. Test on device
# (Connect iPhone, run in Xcode)

# 6. If all passes, distribute
git tag v1.0.0
git push --tags
```

---

## Checklist Before Distribution

Before distributing the package, verify:

- [ ] All 11 XCFrameworks built successfully
- [ ] Each framework has 3 slices (device + 2 simulator)
- [ ] Python.xcframework is included
- [ ] Swift code compiles without warnings
- [ ] Unit tests pass
- [ ] Example app renders video successfully
- [ ] Works on real iOS device (not just simulator)
- [ ] Documentation is complete (README, QUICKSTART, etc.)
- [ ] License file included
- [ ] Version tagged in git
- [ ] Bundle size is reasonable (< 500MB)

---

## Troubleshooting

**Problem: "Framework not found"**
- Ensure framework search paths are set in Xcode
- Check that XCFrameworks are in `Frameworks/` directory

**Problem: "Library not loaded"**
- Verify all libraries are static (.a) not dynamic
- Check linker flags in Package.swift

**Problem: "Python runtime fails"**
- Ensure Python.xcframework is bundled
- Check PYTHONPATH configuration in PythonManager.swift

**Problem: Bundle too large**
- Remove unnecessary architectures (x86_64 if only targeting modern devices)
- Strip debug symbols: `strip -x library.a`
- Compress with better algorithm

---

## Next Steps

After successful bundling and testing:

1. **Performance optimization** - Profile rendering speed
2. **Add more examples** - Create gallery of animations
3. **Write tutorials** - Step-by-step guides
4. **CI/CD setup** - Automate builds with GitHub Actions
5. **Version management** - Semantic versioning strategy
6. **Issue tracking** - Set up GitHub issues
7. **Community** - Create Discord/forum for users
