# Manim iOS Testing Guide

This document outlines how to test the Manim iOS package at different levels to ensure it works correctly.

## Testing Strategy Overview

We'll test at 5 levels:
1. **Library Build Verification** - Check all C libraries are properly built
2. **XCFramework Verification** - Verify framework structure and linking
3. **Swift Package Compilation** - Test Swift code compiles
4. **Python Runtime Test** - Verify Python 3.14 runtime works on iOS
5. **Integration Test** - Full end-to-end Manim rendering test
6. **Example iOS App** - Real-world usage in an iOS application

---

## Level 1: Library Build Verification

### Check All Libraries Are Built

```bash
# Navigate to project
cd /Users/euler/manim

# Check that all 11 libraries have XCFrameworks
ls -lh Frameworks/*.xcframework

# Expected output:
# zlib.xcframework
# libpng.xcframework
# FreeType.xcframework
# Pixman.xcframework
# Expat.xcframework
# FriBidi.xcframework
# HarfBuzz.xcframework
# Cairo.xcframework
# FontConfig.xcframework
# GLib.xcframework
# Pango.xcframework
```

### Verify Each XCFramework Structure

```bash
# Check zlib has all 3 slices
xcodebuild -checkFirstLaunchStatus
xcrun xcodebuild -showBuildSettings -xcframework Frameworks/zlib.xcframework

# Or use file command to check architectures
file Frameworks/zlib.xcframework/*/libz.a

# Expected: 3 files (arm64 device, arm64 sim, x86_64 sim)
```

### Verify Library Symbols

```bash
# Check that libraries have expected symbols
nm Frameworks/libpng.xcframework/ios-arm64/libpng.a | grep png_create_read_struct

# Should show symbol like:
# 0000000000001234 T _png_create_read_struct
```

---

## Level 2: XCFramework Verification

### Create Verification Script

```bash
#!/bin/bash
# verify_frameworks.sh

FRAMEWORKS_DIR="Frameworks"

echo "Verifying XCFrameworks..."

for framework in ${FRAMEWORKS_DIR}/*.xcframework; do
    name=$(basename "$framework" .xcframework)
    echo ""
    echo "=== $name ==="

    # Check Info.plist exists
    if [ ! -f "$framework/Info.plist" ]; then
        echo "❌ Missing Info.plist"
        continue
    fi

    # Count library slices
    slices=$(find "$framework" -name "*.a" | wc -l)
    echo "✓ Found $slices library slices"

    # Check architectures
    for lib in $(find "$framework" -name "*.a"); do
        archs=$(lipo -info "$lib" 2>/dev/null | awk '{print $NF}')
        echo "  $(basename $(dirname $lib)): $archs"
    done
done
```

### Run Verification

```bash
chmod +x verify_frameworks.sh
./verify_frameworks.sh
```

---

## Level 3: Swift Package Compilation Test

### Build Swift Package as Library

```bash
cd /Users/euler/manim

# Build for iOS device
xcodebuild -project Manim.xcodeproj \
    -scheme Manim \
    -sdk iphoneos \
    -destination 'generic/platform=iOS' \
    clean build

# Build for iOS Simulator
xcodebuild -project Manim.xcodeproj \
    -scheme Manim \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    clean build

# Check for build errors
echo $?  # Should be 0
```

### Test Swift Package Manager Integration

Create a test SPM package:

```bash
mkdir -p /tmp/ManimTest
cd /tmp/ManimTest

# Create Package.swift
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ManimTest",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(path: "/Users/euler/manim")
    ],
    targets: [
        .target(
            name: "ManimTest",
            dependencies: ["Manim"]
        )
    ]
)
EOF

# Create test source
mkdir -p Sources/ManimTest
cat > Sources/ManimTest/Test.swift << 'EOF'
import Manim

func testManim() {
    let manim = Manim.shared
    print("Manim initialized: \(manim)")
}
EOF

# Try to build
swift build
```

---

## Level 4: Python Runtime Test

### Test Python 3.14 Runtime Loading

Create a test Swift file:

```swift
// TestPythonRuntime.swift
import Foundation
import PythonKit

func testPythonRuntime() {
    print("Testing Python runtime...")

    // Try to import Python
    let sys = Python.import("sys")
    print("Python version: \(sys.version)")
    print("Python executable: \(sys.executable)")

    // Test basic Python operations
    let result = Python.eval("2 + 2")
    print("2 + 2 = \(result)")

    // Test importing standard library
    let math = Python.import("math")
    print("math.pi = \(math.pi)")

    print("✅ Python runtime test passed!")
}
```

### Check Python.xcframework

```bash
# Verify Python framework exists and is valid
ls -lh Python.xcframework/

# Check architectures
lipo -info Python.xcframework/ios-arm64/Python.framework/Python
lipo -info Python.xcframework/ios-arm64-simulator/Python.framework/Python
```

---

## Level 5: Integration Test - Manim Rendering

### Create Integration Test Script

```swift
// TestManimRendering.swift
import Foundation
import Manim

func testManimRendering() async throws {
    print("=== Manim Integration Test ===\n")

    // Test 1: Initialize Manim
    print("Test 1: Initialize Manim")
    let manim = Manim.shared
    print("✅ Manim initialized\n")

    // Test 2: Create a scene
    print("Test 2: Create scene")
    let scene = try manim.createScene()
    print("✅ Scene created\n")

    // Test 3: Create objects
    print("Test 3: Create circle")
    let circle = try scene.createCircle(radius: 1.0, color: "#FF0000")
    print("✅ Circle created\n")

    print("Test 4: Create text")
    let text = try scene.createText("Hello Manim!")
    print("✅ Text created\n")

    // Test 5: Apply animations
    print("Test 5: Add animations")
    try scene.play(circle.create())
    try scene.play(text.fadeIn())
    print("✅ Animations added\n")

    // Test 6: Configure renderer
    print("Test 6: Configure renderer")
    let config = ManimRenderer.Config(
        quality: .medium,
        format: .mp4,
        fps: 30,
        backgroundColor: "#FFFFFF"
    )
    print("✅ Renderer configured\n")

    // Test 7: Render (this is the critical test)
    print("Test 7: Render scene")
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("test_animation.mp4")

    try await scene.render(to: outputURL, config: config)
    print("✅ Rendering completed\n")

    // Test 8: Verify output
    print("Test 8: Verify output file")
    guard FileManager.default.fileExists(atPath: outputURL.path) else {
        throw NSError(domain: "TestError", code: 1,
                     userInfo: [NSLocalizedDescriptionKey: "Output file not found"])
    }

    let attributes = try FileManager.default.attributesOfItem(atPath: outputURL.path)
    let fileSize = attributes[.size] as? UInt64 ?? 0
    print("Output file size: \(fileSize) bytes")

    guard fileSize > 0 else {
        throw NSError(domain: "TestError", code: 2,
                     userInfo: [NSLocalizedDescriptionKey: "Output file is empty"])
    }

    print("✅ Output file verified\n")
    print("=== All Tests Passed! ===")
}
```

---

## Level 6: Example iOS App

### Create Test App

```bash
# Create new iOS app project
mkdir -p /tmp/ManimTestApp
cd /tmp/ManimTestApp

# Use Xcode to create app, or use xcodeproj
```

### Minimal Test App Code

```swift
// ContentView.swift
import SwiftUI
import Manim
import AVKit

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var isRendering = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Manim iOS Test")
                .font(.title)

            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 300)
            }

            Button(action: renderAnimation) {
                if isRendering {
                    ProgressView()
                } else {
                    Text("Render Animation")
                }
            }
            .disabled(isRendering)

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
    }

    func renderAnimation() {
        isRendering = true
        errorMessage = nil

        Task {
            do {
                let manim = Manim.shared
                let scene = try manim.createScene()

                let circle = try scene.createCircle(radius: 1.0, color: "#FF6B6B")
                try scene.play(circle.create())

                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("animation_\(Date().timeIntervalSince1970).mp4")

                try await scene.render(to: outputURL)

                await MainActor.run {
                    self.videoURL = outputURL
                    self.isRendering = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isRendering = false
                }
            }
        }
    }
}
```

---

## Quick Verification Checklist

Use this checklist to quickly verify the package:

- [ ] All 11 XCFrameworks exist in `Frameworks/`
- [ ] Each XCFramework has 3 slices (arm64, arm64-sim, x86_64-sim)
- [ ] `lipo -info` shows correct architectures for each slice
- [ ] Swift package compiles without errors for iOS device
- [ ] Swift package compiles without errors for iOS Simulator
- [ ] Python.xcframework exists and is valid
- [ ] Can import Manim in Swift code
- [ ] Can create Manim scene
- [ ] Can create Manim objects (Circle, Text, etc.)
- [ ] Can add animations
- [ ] Can render to video file
- [ ] Video file is created and has non-zero size
- [ ] Video file plays correctly in AVPlayer/QuickTime

---

## Automated Test Suite

### Create Full Test Script

```bash
#!/bin/bash
# test_manim_ios.sh - Complete automated test suite

set -e

PROJECT_ROOT="/Users/euler/manim"
cd "$PROJECT_ROOT"

echo "🧪 Manim iOS Test Suite"
echo "======================="
echo ""

# Test 1: Check frameworks
echo "Test 1: Verifying XCFrameworks..."
EXPECTED_FRAMEWORKS=(
    "zlib.xcframework"
    "libpng.xcframework"
    "FreeType.xcframework"
    "Pixman.xcframework"
    "Expat.xcframework"
    "FriBidi.xcframework"
    "HarfBuzz.xcframework"
    "Cairo.xcframework"
    "FontConfig.xcframework"
    "GLib.xcframework"
    "Pango.xcframework"
)

for fw in "${EXPECTED_FRAMEWORKS[@]}"; do
    if [ -d "Frameworks/$fw" ]; then
        echo "  ✅ $fw"
    else
        echo "  ❌ $fw MISSING"
        exit 1
    fi
done
echo ""

# Test 2: Build Swift package
echo "Test 2: Building Swift package..."
xcodebuild -project Manim.xcodeproj \
    -scheme Manim \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    clean build \
    > /tmp/manim_build.log 2>&1

if [ $? -eq 0 ]; then
    echo "  ✅ Swift package builds successfully"
else
    echo "  ❌ Build failed - see /tmp/manim_build.log"
    exit 1
fi
echo ""

# Test 3: Check Python framework
echo "Test 3: Verifying Python framework..."
if [ -d "Python.xcframework" ]; then
    echo "  ✅ Python.xcframework exists"

    # Check version
    if [ -f "Python.xcframework/ios-arm64-simulator/Python.framework/Resources/Info.plist" ]; then
        VERSION=$(plutil -p "Python.xcframework/ios-arm64-simulator/Python.framework/Resources/Info.plist" | grep CFBundleShortVersionString | awk '{print $3}')
        echo "  ✅ Python version: $VERSION"
    fi
else
    echo "  ❌ Python.xcframework MISSING"
    exit 1
fi
echo ""

echo "✅ All automated tests passed!"
echo ""
echo "Next steps:"
echo "1. Run integration tests in Xcode"
echo "2. Test on real iOS device"
echo "3. Create example app and test rendering"
```

---

## Performance Benchmarks

### Test Rendering Performance

```swift
func benchmarkRendering() async throws {
    let iterations = 5
    var times: [TimeInterval] = []

    for i in 1...iterations {
        let start = Date()

        let scene = try Manim.shared.createScene()
        let circle = try scene.createCircle()
        try scene.play(circle.create())

        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent("bench_\(i).mp4")
        try await scene.render(to: output)

        let elapsed = Date().timeIntervalSince(start)
        times.append(elapsed)
        print("Iteration \(i): \(elapsed)s")
    }

    let average = times.reduce(0, +) / Double(times.count)
    print("Average rendering time: \(average)s")
}
```

---

## Troubleshooting Tests

### Common Issues

**Issue: "Framework not found"**
- Check that all XCFrameworks are in `Frameworks/` directory
- Verify Xcode build settings include framework search paths
- Run: `xcodebuild -project Manim.xcodeproj -showBuildSettings | grep FRAMEWORK_SEARCH_PATHS`

**Issue: "Python module not found"**
- Check Python.xcframework is present
- Verify `PYTHONPATH` is set correctly in PythonManager
- Check that manim Python package is included in framework

**Issue: "Symbol not found" linker errors**
- Run `nm` on the library to verify symbols exist
- Check that library was built for correct architecture
- Verify linking order in Xcode project

**Issue: Rendering produces empty file**
- Check that Cairo/Pango are properly initialized
- Verify FFmpeg or video encoding is working
- Test with simpler scene (just one shape)

**Issue: Crash on device but works in simulator**
- Verify arm64 (device) slice is built correctly
- Check code signing and provisioning profiles
- Test bitcode settings (should be disabled)

---

## Device Testing

### Test on Real iOS Device

1. **Connect iPhone/iPad via USB**
2. **Select device in Xcode**
3. **Run test app**
4. **Monitor Console.app for logs**
5. **Check actual rendering performance**

### Device-Specific Checks

```swift
func checkDeviceCapabilities() {
    let device = UIDevice.current
    print("Device: \(device.model)")
    print("iOS version: \(device.systemVersion)")
    print("Available memory: \(ProcessInfo.processInfo.physicalMemory / 1_000_000_000)GB")

    // Test rendering on this specific device
}
```

---

## Success Criteria

The package is considered **ready for production** when:

1. ✅ All 11 XCFrameworks build successfully
2. ✅ Swift package compiles for iOS device and simulator
3. ✅ Python 3.14 runtime initializes correctly
4. ✅ Can create scenes and objects via Swift API
5. ✅ Can add and configure animations
6. ✅ Rendering produces valid video files
7. ✅ Video files play correctly
8. ✅ Works on both simulator and real device
9. ✅ Performance is acceptable (< 10s for simple animation)
10. ✅ No memory leaks during rendering
11. ✅ Example app runs without crashes

---

## Next Steps After Testing

Once all tests pass:

1. **Update documentation** with test results
2. **Create release build** of XCFrameworks
3. **Publish to GitHub** with proper versioning
4. **Create Swift Package** manifest for distribution
5. **Write usage examples** and tutorials
6. **Performance optimization** if needed
7. **Add more example scenes**
