#!/bin/bash

echo "🔍 Verifying Manim iOS Build"
echo "=============================="
echo ""

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
FRAMEWORKS_DIR="Frameworks"

for fw in "${REQUIRED_FRAMEWORKS[@]}"; do
    if [ -d "${FRAMEWORKS_DIR}/${fw}.xcframework" ]; then
        # Count slices (should be 3: arm64 device, arm64 sim, x86_64 sim)
        slices=$(find "${FRAMEWORKS_DIR}/${fw}.xcframework" -name "*.a" | wc -l | xargs)

        if [ "$slices" -eq 3 ]; then
            echo "✅ ${fw}.xcframework ($slices slices)"
        else
            echo "⚠️  ${fw}.xcframework (only $slices slices, expected 3)"
        fi
    else
        echo "❌ ${fw}.xcframework MISSING"
        ALL_PRESENT=false
    fi
done

echo ""

# Check Python framework
if [ -d "Python.xcframework" ]; then
    echo "✅ Python.xcframework"
else
    echo "❌ Python.xcframework MISSING"
    ALL_PRESENT=false
fi

echo ""
echo "Checking framework architectures..."
echo "-----------------------------------"

# Check one framework in detail as example
SAMPLE_FW="${FRAMEWORKS_DIR}/zlib.xcframework"
if [ -d "$SAMPLE_FW" ]; then
    for lib in $(find "$SAMPLE_FW" -name "*.a"); do
        arch_info=$(lipo -info "$lib" 2>/dev/null || echo "error")
        slice_name=$(basename $(dirname "$lib"))
        echo "  $slice_name: $arch_info"
    done
fi

echo ""
if [ "$ALL_PRESENT" = true ]; then
    echo "✅ All frameworks present!"
    exit 0
else
    echo "❌ Some frameworks are missing"
    echo ""
    echo "Run the build scripts to create missing frameworks:"
    echo "  ./scripts/build_all_ios.sh"
    exit 1
fi
