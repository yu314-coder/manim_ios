#!/bin/bash

APP_NAME="ManimTestApp"
OUTPUT_DIR="$HOME/Desktop/$APP_NAME"

echo "🎬 Creating Manim Test App"
echo "=========================="
echo ""

# Check if directory already exists
if [ -d "$OUTPUT_DIR" ]; then
    read -p "⚠️  $OUTPUT_DIR already exists. Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

echo "Creating test app at: $OUTPUT_DIR"
echo ""

# Create Package.swift
cat > "$OUTPUT_DIR/Package.swift" << EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "$APP_NAME",
    platforms: [.iOS(.v13)],
    dependencies: [
        .package(path: "/Users/euler/manim")
    ],
    targets: [
        .executableTarget(
            name: "$APP_NAME",
            dependencies: ["Manim"]
        )
    ]
)
EOF

# Create Sources directory
mkdir -p "$OUTPUT_DIR/Sources/$APP_NAME"

# Create main test file
cat > "$OUTPUT_DIR/Sources/$APP_NAME/main.swift" << 'EOF'
import Foundation
import Manim

print("🧪 Manim iOS Test App")
print("=====================\n")

do {
    // Test 1: Initialize
    print("1️⃣  Initializing Manim...")
    let manim = Manim.shared
    try manim.initialize()
    print("   ✅ Initialized\n")

    // Test 2: Version
    print("2️⃣  Getting version...")
    if let version = manim.version {
        print("   ✅ Version: \(version)\n")
    } else {
        print("   ⚠️  Version not available\n")
    }

    // Test 3: Create scene
    print("3️⃣  Creating scene...")
    let scene = try manim.createScene()
    print("   ✅ Scene created\n")

    // Test 4: Create circle
    print("4️⃣  Creating circle...")
    let circle = scene.createCircle(radius: 1.0, color: "BLUE")
    print("   ✅ Circle created\n")

    // Test 5: Create text
    print("5️⃣  Creating text...")
    let text = scene.createText("Hello Manim!")
    print("   ✅ Text created\n")

    // Test 6: Apply transformations
    print("6️⃣  Applying transformations...")
    try circle.setColor("#FF6B6B")
    try circle.scale(1.5)
    try text.shift(x: 0, y: -2)
    print("   ✅ Transformations applied\n")

    // Test 7: Add animations
    print("7️⃣  Adding animations...")
    try scene.play(circle.create())
    try scene.play(text.fadeIn())
    print("   ✅ Animations added\n")

    print("✅ All tests passed!\n")
    print("Note: Rendering test requires running on actual iOS device or simulator")

} catch {
    print("❌ Error: \(error)")
    exit(1)
}
EOF

# Create README
cat > "$OUTPUT_DIR/README.md" << 'EOF'
# Manim Test App

Simple test application for Manim iOS package.

## Building

```bash
cd ~/Desktop/ManimTestApp
swift build
```

## Running

```bash
swift run
```

## Expected Output

```
🧪 Manim iOS Test App
=====================

1️⃣  Initializing Manim...
   ✅ Initialized

2️⃣  Getting version...
   ✅ Version: 0.x.x

3️⃣  Creating scene...
   ✅ Scene created

4️⃣  Creating circle...
   ✅ Circle created

5️⃣  Creating text...
   ✅ Text created

6️⃣  Applying transformations...
   ✅ Transformations applied

7️⃣  Adding animations...
   ✅ Animations added

✅ All tests passed!
```

## Testing Rendering

To test actual video rendering, you need to run this in an iOS app with a UI.
See the SwiftUI example in BUNDLING.md.
EOF

echo "✅ Test app created!"
echo ""
echo "Location: $OUTPUT_DIR"
echo ""
echo "To test:"
echo "  cd $OUTPUT_DIR"
echo "  swift build"
echo "  swift run"
echo ""
echo "Note: This is a command-line test. For full rendering test,"
echo "      use the SwiftUI app example in BUNDLING.md"
