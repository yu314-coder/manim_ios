# What to Upload to GitHub - Manim iOS

This guide answers: **"What should I upload to GitHub?"**

## TL;DR - Quick Answer

Upload these files to your GitHub repository:

```
✅ All Swift source code (manim/ folder)
✅ Package.swift
✅ All documentation (README.md, etc.)
✅ All 14 XCFrameworks
✅ Python.xcframework
✅ LICENSE file
✅ .gitignore
```

---

## Option 1: Upload Everything (Recommended for Complete Package)

### Files to Upload

```
manim-ios/                          ← Your GitHub repo
│
├── .gitignore                      ✅ Upload
├── LICENSE                         ✅ Upload
├── README.md                       ✅ Upload
├── Package.swift                   ✅ Upload
│
├── manim/                          ✅ Upload (entire folder)
│   ├── Manim.swift
│   ├── PythonManager.swift
│   ├── ManimBridge.swift
│   ├── ManimScene.swift
│   ├── ManimObject.swift
│   ├── ManimRenderer.swift
│   └── ManimExample.swift
│
├── Frameworks/                     ✅ Upload (all 14 .xcframework bundles)
│   ├── Cairo.xcframework/
│   ├── Pango.xcframework/
│   ├── HarfBuzz.xcframework/
│   ├── FontConfig.xcframework/
│   ├── FreeType.xcframework/
│   ├── GLib.xcframework/
│   ├── GObject.xcframework/
│   ├── FriBidi.xcframework/
│   ├── Pixman.xcframework/
│   ├── libpng.xcframework/
│   ├── zlib.xcframework/
│   ├── Expat.xcframework/
│   ├── libffi.xcframework/
│   └── PCRE2.xcframework/
│
├── Python.xcframework/             ✅ Upload (if not too large)
│
└── Documentation/                  ✅ Upload (optional but recommended)
    ├── QUICKSTART.md
    ├── INSTALLATION.md
    ├── TESTING.md
    ├── BUNDLING.md
    ├── GITHUB_UPLOAD.md (this file)
    └── QUICK_REFERENCE.md
```

### DO NOT Upload

```
❌ ios_build/                       (build artifacts)
❌ .build/                          (Swift Package Manager cache)
❌ .swiftpm/                        (SPM cache)
❌ dist/                            (distribution bundles)
❌ *.tar.gz                         (archives)
❌ DerivedData/                     (Xcode build cache)
❌ .DS_Store                        (macOS files)
```

---

## Option 2: Upload with Git LFS (For Large Files)

**Problem:** GitHub has 100MB file size limit. Some frameworks might exceed this.

**Solution:** Use Git Large File Storage (LFS)

### Setup Git LFS

```bash
cd /Users/euler/manim

# Install Git LFS (if not installed)
brew install git-lfs
git lfs install

# Track large files
git lfs track "Frameworks/*.xcframework/**"
git lfs track "Python.xcframework/**"

# Add .gitattributes
git add .gitattributes
git commit -m "Configure Git LFS for frameworks"
```

### Then Upload Everything

```bash
git add .
git commit -m "Initial commit: Manim iOS package"
git push
```

**Note:** GitHub Free has 1GB/month LFS bandwidth limit.

---

## Option 3: Upload Source + Host Frameworks Separately (Best for Public Projects)

If frameworks are too large for GitHub/LFS, use this hybrid approach:

### Upload to GitHub

```
✅ manim/                           (Swift source)
✅ Package.swift                    (manifest)
✅ README.md + docs                 (documentation)
✅ LICENSE
✅ scripts/download_frameworks.sh   (download script)
```

### Host Frameworks Externally

Upload frameworks to:
- GitHub Releases (recommended, supports large files)
- Google Drive / Dropbox
- Your own server
- Amazon S3

### Create Download Script

Create `scripts/download_frameworks.sh`:

```bash
#!/bin/bash

echo "Downloading Manim iOS frameworks..."

# Download from GitHub Releases
curl -L -o Frameworks.zip \
  "https://github.com/yourusername/manim-ios/releases/download/v1.0.0/Frameworks.zip"

unzip Frameworks.zip
rm Frameworks.zip

echo "✅ Frameworks installed!"
```

Users run:
```bash
git clone https://github.com/yourusername/manim-ios.git
cd manim-ios
./scripts/download_frameworks.sh
```

---

## Step-by-Step Upload Process

### 1. Prepare .gitignore

Create `/Users/euler/manim/.gitignore`:

```gitignore
# Build artifacts
ios_build/
build/
*.o
*.a

# Swift Package Manager
.build/
.swiftpm/

# Distribution bundles
dist/
*.tar.gz
*.zip

# Xcode
DerivedData/
*.xcodeproj
xcuserdata/
*.xcworkspace
!*.xcworkspace/contents.xcworkspacedata

# macOS
.DS_Store

# Logs
*.log

# If hosting frameworks externally, uncomment:
# Frameworks/
# Python.xcframework/
```

### 2. Create LICENSE

If you don't have one, the bundle.sh script will create a MIT license for you.

Or create manually:

```bash
cd /Users/euler/manim

cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
```

### 3. Initialize Git (if not done)

```bash
cd /Users/euler/manim

git init
git add .gitignore LICENSE
```

### 4. Add Files to Git

**If uploading everything:**
```bash
git add manim/ Frameworks/ Python.xcframework/
git add Package.swift README.md *.md
git commit -m "Initial commit: Manim iOS package v1.0.0"
```

**If using Git LFS:**
```bash
git lfs track "Frameworks/**" "Python.xcframework/**"
git add .gitattributes
git add .
git commit -m "Initial commit: Manim iOS package v1.0.0"
```

**If hosting frameworks separately:**
```bash
# Only add source code and docs
git add manim/ Package.swift README.md *.md scripts/
git commit -m "Initial commit: Manim iOS package v1.0.0"
```

### 5. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `manim-ios`
3. Description: "Mathematical Animation Engine (Manim) for iOS - Complete rendering stack with Python 3.14"
4. Public or Private (your choice)
5. **DO NOT** initialize with README (you already have one)
6. Click "Create repository"

### 6. Push to GitHub

```bash
# Add remote
git remote add origin https://github.com/yourusername/manim-ios.git

# Push main branch
git branch -M main
git push -u origin main
```

### 7. Create Release (If Using External Frameworks)

If you're hosting frameworks separately:

```bash
# Create frameworks archive
cd /Users/euler/manim
zip -r Frameworks.zip Frameworks/ Python.xcframework/

# On GitHub:
# 1. Go to your repo → Releases → Create new release
# 2. Tag: v1.0.0
# 3. Title: "Manim iOS 1.0.0"
# 4. Upload Frameworks.zip as release asset
# 5. Publish
```

---

## Recommended Upload Strategy

Based on file sizes:

### Check Framework Sizes First

```bash
cd /Users/euler/manim
du -sh Frameworks/*.xcframework | sort -h
du -sh Python.xcframework
```

**If total < 1 GB:** Use Option 1 or 2 (upload everything)
**If total > 1 GB:** Use Option 3 (GitHub Releases for frameworks)

---

## GitHub Repository Settings

After uploading, configure your repo:

### 1. Topics

Add topics to help people find your package:
- `ios`
- `swift`
- `manim`
- `animation`
- `mathematics`
- `swift-package-manager`
- `graphics`
- `python`

### 2. Description

```
Mathematical Animation Engine (Manim) for iOS. Create beautiful mathematical
animations natively on iPhone and iPad. Includes complete rendering stack
(Cairo, Pango, HarfBuzz, etc.) + Python 3.14 runtime.
```

### 3. Website (optional)

Link to Manim community: `https://www.manim.community`

---

## What Users Will See

After you upload, users can install your package:

### Via Swift Package Manager

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/yourusername/manim-ios.git", from: "1.0.0")
]
```

### Via Xcode

1. File → Add Package Dependencies
2. Enter: `https://github.com/yourusername/manim-ios`
3. Select version
4. Add to project

---

## Updating Your Package

When you make changes:

```bash
cd /Users/euler/manim

# Make changes to code
git add .
git commit -m "Description of changes"
git push

# Create new version tag
git tag v1.0.1
git push --tags
```

---

## Final Checklist

Before uploading to GitHub:

- [ ] All 14 XCFrameworks are built and verified
- [ ] Python.xcframework exists
- [ ] README.md is complete and accurate
- [ ] LICENSE file exists
- [ ] .gitignore excludes build artifacts
- [ ] Package.swift is correctly configured
- [ ] Documentation files are included
- [ ] You've decided on upload strategy (direct vs LFS vs releases)
- [ ] You've tested the package locally
- [ ] You've chosen a repository name
- [ ] You have a GitHub account

---

## Example GitHub Repository Structure

```
https://github.com/yourusername/manim-ios
│
├── 📄 README.md                    ← First thing users see
├── 📄 LICENSE                      ← Legal protection
├── 📄 Package.swift                ← SPM integration
├── 📄 .gitignore                   ← Exclude artifacts
│
├── 📂 manim/                       ← Swift source (7 files)
├── 📂 Frameworks/                  ← 14 XCFrameworks
├── 📂 Python.xcframework/          ← Python 3.14 runtime
│
├── 📂 Documentation/               ← Guides (optional)
│   ├── QUICKSTART.md
│   ├── INSTALLATION.md
│   ├── TESTING.md
│   └── BUNDLING.md
│
└── 📂 scripts/                     ← Helper scripts (optional)
    ├── verify_build.sh
    ├── bundle.sh
    └── download_frameworks.sh
```

---

## Common Questions

**Q: Should I upload build scripts?**
A: Optional. Not needed for users, but helpful for contributors.

**Q: Should I upload ios_build/ directory?**
A: No. This contains build artifacts and source archives. Add to .gitignore.

**Q: How to handle large frameworks?**
A: Use GitHub Releases or Git LFS. See Option 2 and 3 above.

**Q: Can I make the repository private?**
A: Yes, but users won't be able to install via SPM without access.

**Q: Should I include examples?**
A: Yes! Add an `Examples/` folder with sample iOS apps.

**Q: What about versioning?**
A: Use semantic versioning: v1.0.0, v1.1.0, v2.0.0, etc.

---

## Summary

**Minimum required files:**
- `manim/` (Swift source)
- `Frameworks/` (all 14 XCFrameworks)
- `Python.xcframework/`
- `Package.swift`
- `README.md`
- `LICENSE`

**Recommended additional files:**
- Documentation (QUICKSTART.md, etc.)
- `.gitignore`
- Helper scripts

**Choose upload strategy based on size:**
- Small (< 1GB): Upload everything directly
- Medium (1-5GB): Use Git LFS
- Large (> 5GB): Use GitHub Releases for frameworks

---

## Ready to Upload!

Follow the step-by-step process above, and your Manim iOS package will be live on GitHub for the world to use! 🎉
