# Manim iOS

**✅ COMPLETE** - Full Manim rendering engine for iOS with all dependencies built!

A Swift package that brings the powerful Manim (Mathematical Animation Engine) library to iOS, enabling you to create beautiful mathematical animations directly on iPhone and iPad.

## 🎉 What's New

**All C library dependencies successfully compiled for iOS!**
- ✅ All 14 frameworks built (zlib, libpng, FreeType, Pixman, Expat, FriBidi, HarfBuzz, Cairo, FontConfig, libffi, PCRE2, GLib, GObject, Pango)
- ✅ Support for iOS device (arm64) + Simulator (arm64, x86_64)
- ✅ Ready for integration into iOS apps
- ✅ Complete Swift API wrapper

## Features

- 🎨 Create mathematical animations using Manim's powerful API
- 📱 Native iOS support (devices + simulators)
- 🎥 Render animations to MP4 video files
- 📐 Full text rendering with Pango
- 🔤 Font support via FontConfig
- 🎭 Hardware-accelerated graphics via Cairo
- 🐍 Python 3.14 runtime embedded

## Quick Start

### Installation

#### Option 1: Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/manim-ios.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter repository URL
3. Add to your target

#### Option 2: Local Package

1. Clone this repository
2. In Xcode: File → Add Package Dependencies → Add Local
3. Select the `manim` folder

### Basic Usage

```swift
import Manim

// Initialize Manim
let manim = Manim.shared
try manim.initialize()

// Create a scene
let scene = try manim.createScene()

// Add a circle
let circle = scene.createCircle(radius: 1.0, color: "BLUE")
try scene.play(circle.create())

// Render to video
let outputURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("animation.mp4")

let config = ManimRenderer.Config(
    quality: .high,
    format: .mp4,
    fps: 60
)

try await scene.render(to: outputURL, config: config)

// Video file is ready at outputURL!
```

## Architecture

```
iOS App
   ↓
Swift API (manim/*.swift)
   ↓
PythonKit Bridge
   ↓
Python 3.14 Runtime
   ↓
Manim Library
   ↓
C Libraries (Cairo, Pango, etc.)
   ↓
Video Output (MP4)
```

## Package Structure

```
manim/
├── manim/                       # Swift source code
│   ├── manim.swift             # Main entry point
│   ├── PythonManager.swift     # Python runtime manager
│   ├── ManimBridge.swift       # Swift-Python bridge
│   ├── ManimScene.swift        # Scene management
│   ├── ManimObject.swift       # Object transformations
│   ├── ManimRenderer.swift     # Video rendering
│   └── ManimExample.swift      # Usage examples
├── Frameworks/                  # Pre-built XCFrameworks
│   ├── Cairo.xcframework       # Graphics rendering
│   ├── Pango.xcframework       # Text rendering
│   ├── HarfBuzz.xcframework    # Text shaping
│   ├── FontConfig.xcframework  # Font management
│   ├── FreeType.xcframework    # Font rasterization
│   ├── GLib.xcframework        # Core utilities
│   ├── GObject.xcframework     # Object system
│   ├── FriBidi.xcframework     # Unicode BiDi
│   ├── Pixman.xcframework      # Pixel manipulation
│   ├── libpng.xcframework      # PNG support
│   ├── zlib.xcframework        # Compression
│   ├── Expat.xcframework       # XML parsing
│   ├── libffi.xcframework      # Foreign function interface
│   └── PCRE2.xcframework       # Regular expressions
├── Python.xcframework/          # Python 3.14 runtime
├── Package.swift               # Swift Package manifest
└── Documentation/              # Guides and references
```

## Swift API Reference

### Creating Scenes

```swift
// Initialize Manim
let manim = Manim.shared
try manim.initialize()

// Get version
print("Manim version: \(manim.version ?? "unknown")")

// Create scene
let scene = try manim.createScene()
```

### Creating Objects

```swift
// Shapes
let circle = scene.createCircle(radius: 1.0, color: "BLUE")
let square = scene.createSquare(sideLength: 2.0, color: "RED")

// Text
let text = scene.createText("Hello, World!", fontSize: 48)

// Math equations
let equation = scene.createMathTex("E = mc^2")
```

### Transformations

```swift
// Position
try circle.shift(x: 2, y: 1, z: 0)
try circle.moveTo(x: 0, y: 0, z: 0)

// Scale and rotation
try circle.scale(1.5)
try circle.rotate(angle: .pi / 4)

// Styling
try circle.setColor("#FF6B6B")
try circle.setOpacity(0.7)
```

### Animations

```swift
// Object creation
try scene.play(circle.create())

// Fading
try scene.play(circle.fadeIn())
try scene.play(circle.fadeOut())

// Transformation
try scene.play(circle.transform(to: square))

// Wait
try scene.wait(duration: 2.0)
```

### Rendering

```swift
// Configure renderer
let config = ManimRenderer.Config(
    quality: .high,        // .low, .medium, .high, .fourk
    format: .mp4,          // .mp4, .mov, .gif
    fps: 60,               // Frames per second
    backgroundColor: "#FFFFFF"
)

// Render to file
let outputURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("my_animation.mp4")

try await scene.render(to: outputURL, config: config)

// Check if file exists
if FileManager.default.fileExists(atPath: outputURL.path) {
    print("✅ Animation rendered: \(outputURL)")
}
```

## Complete Example

```swift
import SwiftUI
import Manim
import AVKit

struct ContentView: View {
    @State private var videoURL: URL?
    @State private var isRendering = false

    var body: some View {
        VStack {
            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .frame(height: 400)
            }

            Button("Create Animation") {
                createAnimation()
            }
            .disabled(isRendering)
        }
    }

    func createAnimation() {
        isRendering = true

        Task {
            do {
                // Initialize Manim
                let manim = Manim.shared
                try manim.initialize()

                // Create scene
                let scene = try manim.createScene()

                // Create shapes
                let circle = scene.createCircle(radius: 1.0, color: "BLUE")
                let square = scene.createSquare(sideLength: 2.0, color: "RED")

                // Animate
                try scene.play(circle.create())
                try scene.wait(duration: 1.0)
                try scene.play(circle.transform(to: square))

                // Render
                let output = FileManager.default.temporaryDirectory
                    .appendingPathComponent("animation.mp4")

                try await scene.render(to: output)

                await MainActor.run {
                    self.videoURL = output
                    self.isRendering = false
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    self.isRendering = false
                }
            }
        }
    }
}
```

## Requirements

- iOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Documentation

- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Detailed integration guide
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[TESTING.md](TESTING.md)** - Testing strategies
- **[BUNDLING.md](BUNDLING.md)** - Distribution guide
- **[BUILD_STATUS.md](BUILD_STATUS.md)** - Build information

## Built With

This package includes the following open-source libraries, all cross-compiled for iOS:

| Library | Version | Purpose |
|---------|---------|---------|
| Cairo | 1.18.0 | 2D graphics rendering |
| Pango | 1.52.0 | Text layout and rendering |
| HarfBuzz | 8.3.0 | Text shaping |
| FontConfig | 2.15.0 | Font configuration |
| FreeType | 2.13.2 | Font rasterization |
| GLib | 2.82.4 | Core utilities |
| FriBidi | 1.0.13 | Unicode BiDi algorithm |
| Pixman | 0.44.2 | Pixel manipulation |
| libpng | 1.6.43 | PNG image support |
| zlib | 1.3.1 | Compression |
| Expat | 2.6.4 | XML parsing |
| libffi | 3.4.7 | Foreign function interface |
| PCRE2 | 10.44 | Regular expressions |
| Python | 3.14 | Runtime environment |

## Performance Notes

- **Rendering speed**: Varies by complexity, ~2-10 seconds for simple animations
- **Bundle size**: Adds approximately 200-300 MB to your app
- **Memory usage**: Depends on animation complexity
- **Supported formats**: MP4, MOV, GIF

## Limitations

- LaTeX rendering not yet implemented (use MathTex for basic equations)
- 3D rendering not supported
- Real-time animation not optimized (render to video first)
- Requires Python runtime (~50MB overhead)

## Troubleshooting

### "Framework not found" error
Make sure all XCFrameworks are included in your project. Check Xcode build settings for framework search paths.

### "Python module not found"
Ensure Python.xcframework is bundled with your app and PYTHONPATH is configured correctly.

### Rendering produces empty file
Check that Cairo and Pango libraries are properly linked. Verify with simple test animation first.

### App crashes on device but works in simulator
Verify that all frameworks have the correct arm64 device slice. Use `lipo -info` to check.

## Examples

See `ManimExample.swift` for complete working examples:

```swift
// Example 1: Simple circle
try await ManimExample.example1_SimpleCircle()

// Example 2: Text animation
try await ManimExample.example2_TextAnimation()

// Example 3: Shape transformation
try await ManimExample.example3_Transformation()

// Example 4: Math equation
try await ManimExample.example4_MathEquation()
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Credits

- **Manim Community** - Original Manim library
- **3Blue1Brown** - Creator of original Manim
- **Cairo Graphics** - 2D graphics library
- **Pango** - Text rendering engine
- **PythonKit** - Swift-Python bridge

## Support

- 📖 [Documentation](./Documentation/)
- 🐛 [Issue Tracker](https://github.com/yourusername/manim-ios/issues)
- 💬 [Discussions](https://github.com/yourusername/manim-ios/discussions)

---

**Built with ❤️ for iOS developers who love mathematical animations**
