# GitHub Upload Instructions

This folder is ready to upload to GitHub!

## Quick Start

### 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `manim-ios`
3. Description: `Mathematical Animation Engine (Manim) for iOS - Complete rendering stack`
4. Choose **Public** (recommended for Swift Package Manager)
5. **DO NOT** check "Initialize this repository with a README"
6. Click "Create repository"

### 2. Upload This Folder to GitHub

```bash
# Navigate to this folder
cd /Users/euler/manim/github-upload/UPLOAD_TO_GIT

# Initialize git
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Manim iOS v1.0.0

Complete Manim rendering engine for iOS with all dependencies built!

Features:
- ✅ All 14 frameworks (Cairo, Pango, HarfBuzz, etc.)
- ✅ Support for iOS device (arm64) + Simulator (arm64, x86_64)
- ✅ Complete Swift API wrapper
- ✅ Ready for integration into iOS apps

Requirements:
- iOS 13.0+
- Xcode 15.0+
- Swift 5.9+"

# Add your GitHub repository as remote (replace yourusername!)
git remote add origin https://github.com/yourusername/manim-ios.git

# Rename branch to main
git branch -M main

# Push to GitHub
git push -u origin main
```

### 3. Create GitHub Release with Frameworks

Since frameworks are large (225 MB), upload them via GitHub Releases:

```bash
# The frameworks are already zipped: ../Frameworks-v1.0.0.zip

# On GitHub:
1. Go to your repository: https://github.com/yourusername/manim-ios
2. Click "Releases" → "Create a new release"
3. Tag: v1.0.0
4. Title: Manim iOS 1.0.0 - Initial Release
5. Description: (see below)
6. Attach file: Upload ../Frameworks-v1.0.0.zip
7. Click "Publish release"
```

**Release Description Template:**

```markdown
# Manim iOS 1.0.0

Complete Manim rendering engine for iOS with all dependencies built!

## 🎉 What's Included

- ✅ All 14 frameworks built (Cairo, Pango, HarfBuzz, FontConfig, FreeType, GLib, FriBidi, Pixman, libpng, zlib, Expat, libffi, PCRE2, GObject)
- ✅ Support for iOS device (arm64) + Simulator (arm64, x86_64)
- ✅ Complete Swift API wrapper
- ✅ Python 3.14 runtime
- ✅ Ready for integration into iOS apps

## 📦 Installation

### Option 1: Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/manim-ios.git", from: "1.0.0")
]
```

### Option 2: Manual Installation

1. Download `Frameworks-v1.0.0.zip` from this release
2. Extract to get `Frameworks/` and `Python.xcframework/`
3. Copy them to your project root
4. Clone or download the source code
5. Add to your Xcode project

## 🚀 Quick Start

```swift
import Manim

let manim = Manim.shared
try manim.initialize()

let scene = try manim.createScene()
let circle = scene.createCircle(radius: 1.0, color: "BLUE")
try scene.play(circle.create())

try await scene.render(to: outputURL)
```

## 📋 Requirements

- iOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## 📖 Documentation

- [README.md](README.md) - Overview and API reference
- [GITHUB_UPLOAD.md](GITHUB_UPLOAD.md) - Upload instructions
- [BUNDLING.md](BUNDLING.md) - Distribution guide
- [TESTING.md](TESTING.md) - Testing strategies

## 🔧 What's in Frameworks.zip

All 14 pre-built XCFrameworks:
- Cairo 1.18.0
- Pango 1.52.0
- HarfBuzz 8.3.0
- FontConfig 2.15.0
- FreeType 2.13.2
- GLib 2.82.4
- Plus 8 more libraries
- Python 3.14 runtime

Total size: ~225 MB
```

### 4. Add Repository Topics

After creating the repo, add these topics:

- `ios`
- `swift`
- `manim`
- `animation`
- `mathematics`
- `swift-package-manager`
- `graphics`
- `python`
- `cairo`
- `rendering`

### 5. Verify Upload

Check that these are visible on GitHub:

- [ ] README.md displays on repository home page
- [ ] All source files in `manim/` folder
- [ ] Package.swift is present
- [ ] LICENSE file is visible
- [ ] Documentation files are accessible
- [ ] v1.0.0 release is created
- [ ] Frameworks-v1.0.0.zip is attached to release

## 🎯 Users Can Then Install

### Via Swift Package Manager (Xcode)

1. File → Add Package Dependencies
2. Enter: `https://github.com/yourusername/manim-ios`
3. Select version 1.0.0
4. Download Frameworks-v1.0.0.zip from Releases
5. Extract and add to project

### Via Command Line

```bash
git clone https://github.com/yourusername/manim-ios.git
cd manim-ios

# Download frameworks from releases
curl -L -O https://github.com/yourusername/manim-ios/releases/download/v1.0.0/Frameworks-v1.0.0.zip

# Extract
unzip Frameworks-v1.0.0.zip
```

## 🆘 Troubleshooting

**Error: "Permission denied"**
- Make sure you're authenticated with GitHub
- Run: `git config --global user.name "Your Name"`
- Run: `git config --global user.email "your@email.com"`

**Error: "Repository not found"**
- Make sure you created the repository on GitHub first
- Check the remote URL is correct

**Error: "Files too large"**
- Don't worry! Frameworks go in GitHub Releases, not the git repo
- This folder only contains source code (~1 MB)

## ✅ Success!

Once uploaded, your repository will be at:
`https://github.com/yourusername/manim-ios`

Anyone can now install and use your Manim iOS package!
