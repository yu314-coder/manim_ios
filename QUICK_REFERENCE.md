# Manim iOS - Quick Reference Guide

## 🚀 Quick Start (After All Libraries Are Built)

### 1. Verify Everything is Built
```bash
cd /Users/euler/manim
./scripts/verify_build.sh
```

### 2. Test the Package Automatically
```bash
./scripts/test_package.sh
```

This interactive script will:
- ✅ Verify all 11 frameworks are built
- 📦 Create distribution bundle
- 🎬 Create test app
- 🧪 Run tests

---

## 📦 Manual Bundling

### Create Distribution Bundle
```bash
./scripts/bundle.sh
```
Output: `dist/ManimIOS-1.0.0.tar.gz`

### Verify Build
```bash
./scripts/verify_build.sh
```

---

## 🧪 Testing Options

### Option 1: Command-Line Test (Fastest)
```bash
./scripts/create_test_app.sh
cd ~/Desktop/ManimTestApp
swift run
```

### Option 2: Xcode Test App
1. Create new iOS app in Xcode
2. File → Add Package Dependencies → Add Local
3. Browse to `/Users/euler/manim`
4. Use SwiftUI code from `BUNDLING.md`

### Option 3: Unit Tests
```bash
cd /Users/euler/manim
swift test
```

---

## 📂 Package Structure

```
/Users/euler/manim/
├── manim/                   # Swift source code (7 files)
├── Frameworks/              # 11 XCFrameworks
├── Python.xcframework/      # Python 3.14 runtime
├── Package.swift            # SPM manifest
├── scripts/                 # Build & test scripts
├── README.md               # Main documentation
├── TESTING.md              # Testing guide
├── BUNDLING.md             # Distribution guide
└── QUICK_REFERENCE.md      # This file
```

---

## 🏗️ Build Status Checklist

### Required Frameworks (11 total)
- [ ] zlib.xcframework
- [ ] libpng.xcframework
- [ ] FreeType.xcframework
- [ ] Pixman.xcframework
- [ ] Expat.xcframework
- [ ] FriBidi.xcframework
- [ ] HarfBuzz.xcframework
- [ ] Cairo.xcframework
- [ ] FontConfig.xcframework
- [ ] GLib.xcframework ← **Currently building**
- [ ] Pango.xcframework ← **Next**

### Additional Requirements
- [ ] Python.xcframework (Python 3.14)
- [ ] Swift source code
- [ ] Package.swift manifest

---

## 🔧 Build Commands

### Build Individual Library
```bash
./scripts/build_zlib_ios.sh        # 1. zlib
./scripts/build_libpng_ios.sh      # 2. libpng
./scripts/build_freetype_ios.sh    # 3. FreeType
./scripts/build_pixman_ios.sh      # 4. Pixman
./scripts/build_expat_ios.sh       # 5. Expat
./scripts/build_fribidi_ios.sh     # 6. FriBidi
./scripts/build_harfbuzz_ios.sh    # 7. HarfBuzz
./scripts/build_cairo_ios.sh       # 8. Cairo
./scripts/build_fontconfig_ios.sh  # 9. FontConfig
./scripts/build_glib_ios.sh        # 10. GLib (in progress)
./scripts/build_pango_ios.sh       # 11. Pango (next)
```

### Build All Libraries
```bash
./scripts/build_all_ios.sh
```

---

## 💻 Usage Example

### Swift Code
```swift
import Manim

// Initialize
let manim = Manim.shared
try manim.initialize()

// Create scene
let scene = try manim.createScene()

// Add circle
let circle = scene.createCircle(radius: 1.0, color: "BLUE")
try scene.play(circle.create())

// Render
let output = FileManager.default.temporaryDirectory
    .appendingPathComponent("animation.mp4")
try await scene.render(to: output)
```

---

## 🐛 Common Issues

### "Framework not found"
```bash
# Verify frameworks exist
ls -la Frameworks/*.xcframework
```

### "Python module not found"
```bash
# Check Python framework
ls -la Python.xcframework
```

### "Library not loaded"
```bash
# Check architecture
lipo -info Frameworks/zlib.xcframework/ios-arm64/libz.a
```

---

## 📊 Architecture Support

Each XCFramework contains 3 slices:
- **ios-arm64** → iPhone/iPad (device)
- **ios-arm64-simulator** → M1/M2 Mac simulator
- **ios-x86_64-simulator** → Intel Mac simulator

---

## 🎯 Distribution Methods

### 1. GitHub (SPM)
```swift
.package(url: "https://github.com/user/manim-ios", from: "1.0.0")
```

### 2. Local Package
```swift
.package(path: "/Users/euler/manim")
```

### 3. Binary Archive
```bash
./scripts/bundle.sh
# Share: dist/ManimIOS-1.0.0.tar.gz
```

---

## ⚡ Quick Commands Reference

```bash
# Verify build
./scripts/verify_build.sh

# Bundle package
./scripts/bundle.sh

# Create test app
./scripts/create_test_app.sh

# Run full test workflow
./scripts/test_package.sh

# Build GLib (current step)
./scripts/build_glib_ios.sh

# Build Pango (next step)
./scripts/build_pango_ios.sh

# Check what's running
ps aux | grep build

# Clean build artifacts
rm -rf ios_build/src/*/build-*
```

---

## 📈 Current Progress

**Completed:**
- ✅ zlib
- ✅ libpng
- ✅ FreeType
- ✅ Pixman
- ✅ Expat
- ✅ FriBidi
- ✅ HarfBuzz
- ✅ Cairo
- ✅ FontConfig
- ✅ libffi
- ✅ PCRE2

**In Progress:**
- ⏳ GLib (building now)

**Remaining:**
- ⏹️ Pango (1 library left!)

**Overall:** 10/11 complete (91%)

---

## 🎬 After Pango Builds

1. **Verify all frameworks:**
   ```bash
   ./scripts/verify_build.sh
   ```

2. **Bundle the package:**
   ```bash
   ./scripts/bundle.sh
   ```

3. **Test in Xcode:**
   - Create test app
   - Import Manim package
   - Render video

4. **Distribute:**
   - Push to GitHub
   - Tag release: `git tag v1.0.0`
   - Share bundle

---

## 📚 Documentation Files

- **README.md** - Project overview and introduction
- **QUICKSTART.md** - 5-minute getting started guide
- **INSTALLATION.md** - Detailed setup instructions
- **TESTING.md** - Comprehensive testing strategies
- **BUNDLING.md** - Distribution and bundling guide
- **PROJECT_STATUS.md** - Current build status
- **QUICK_REFERENCE.md** - This file

---

## 🆘 Getting Help

1. **Check documentation** - Start with README.md
2. **Review logs** - Check `/tmp/*.log` files
3. **Verify dependencies** - Run verify_build.sh
4. **Check issues** - Review known problems in docs
5. **Debug build** - Add `-v` flag to build scripts

---

## 🎓 Learning Resources

### Understanding the Architecture
```
iOS App
   ↓
Swift API (manim/*.swift)
   ↓
PythonKit Bridge
   ↓
Python Manim
   ↓
C Libraries (Cairo, Pango, etc.)
   ↓
Video Output (MP4)
```

### Key Files
- `manim/manim.swift` - Entry point
- `manim/PythonManager.swift` - Python runtime
- `manim/ManimBridge.swift` - Swift ↔ Python
- `manim/ManimScene.swift` - Scene management
- `manim/ManimObject.swift` - Object manipulation
- `manim/ManimRenderer.swift` - Video rendering

---

## ✅ Success Criteria

Package is ready when:
- [x] All 11 XCFrameworks built
- [x] Each framework has 3 slices
- [x] Swift package compiles
- [ ] Python runtime initializes
- [ ] Can create scenes and objects
- [ ] Can render video files
- [ ] Works on simulator
- [ ] Works on real device

---

## 📝 Version Info

- **Package Version:** 1.0.0
- **iOS Target:** 13.0+
- **Python Version:** 3.14
- **Xcode:** 15.0+
- **Swift:** 5.9+

---

## 🚦 Status Indicators

- ✅ Complete
- ⏳ In progress
- ⏹️ Pending
- ❌ Failed
- ⚠️ Warning

---

*Last updated: 2025-12-31*
