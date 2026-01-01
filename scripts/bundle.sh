#!/bin/bash

BUNDLE_NAME="ManimIOS"
BUNDLE_VERSION="1.0.0"
OUTPUT_DIR="dist"

echo "📦 Bundling Manim iOS v${BUNDLE_VERSION}"
echo "======================================="
echo ""

# Clean previous bundle
echo "Cleaning previous bundles..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/$BUNDLE_NAME"

# Copy frameworks
echo "Copying XCFrameworks..."
if [ -d "Frameworks" ]; then
    cp -R Frameworks "$OUTPUT_DIR/$BUNDLE_NAME/"
    echo "  ✅ Frameworks copied"
else
    echo "  ❌ Frameworks directory not found!"
    exit 1
fi

# Copy Python framework
echo "Copying Python framework..."
if [ -d "Python.xcframework" ]; then
    cp -R Python.xcframework "$OUTPUT_DIR/$BUNDLE_NAME/"
    echo "  ✅ Python.xcframework copied"
else
    echo "  ⚠️  Python.xcframework not found (you'll need to add it)"
fi

# Copy Swift sources
echo "Copying Swift sources..."
if [ -d "manim" ]; then
    cp -R manim "$OUTPUT_DIR/$BUNDLE_NAME/"
    echo "  ✅ Swift sources copied"
else
    echo "  ❌ manim directory not found!"
    exit 1
fi

# Copy package manifest
echo "Copying package manifest..."
if [ -f "Package.swift" ]; then
    cp Package.swift "$OUTPUT_DIR/$BUNDLE_NAME/"
    echo "  ✅ Package.swift copied"
else
    echo "  ❌ Package.swift not found!"
    exit 1
fi

# Copy documentation
echo "Copying documentation..."
for doc in README.md QUICKSTART.md INSTALLATION.md TESTING.md BUNDLING.md PROJECT_STATUS.md; do
    if [ -f "$doc" ]; then
        cp "$doc" "$OUTPUT_DIR/$BUNDLE_NAME/"
        echo "  ✅ $doc"
    else
        echo "  ⚠️  $doc not found"
    fi
done

# Create LICENSE if not exists
if [ ! -f "LICENSE" ]; then
    echo "Creating MIT LICENSE..."
    cat > "$OUTPUT_DIR/$BUNDLE_NAME/LICENSE" << 'EOF'
MIT License

Copyright (c) 2025 Manim iOS

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
else
    cp LICENSE "$OUTPUT_DIR/$BUNDLE_NAME/"
fi

# Create archive
echo ""
echo "Creating archive..."
cd "$OUTPUT_DIR"
tar -czf "${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz" "$BUNDLE_NAME"
cd ..

echo ""
echo "✅ Bundle created successfully!"
echo ""
echo "Bundle location: $OUTPUT_DIR/${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz"

# Calculate size
SIZE=$(du -h "$OUTPUT_DIR/${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz" | awk '{print $1}')
echo "Bundle size: $SIZE"

echo ""
echo "Bundle contents:"
ls -lh "$OUTPUT_DIR/$BUNDLE_NAME" | tail -n +2 | awk '{print "  " $9}'

echo ""
echo "To distribute:"
echo "  1. Upload to GitHub releases"
echo "  2. Or share the .tar.gz file directly"
echo "  3. Users extract with: tar -xzf ${BUNDLE_NAME}-${BUNDLE_VERSION}.tar.gz"
