#!/bin/bash
# Kit Collection & Installation Script
# Gathers all module outputs from central collection points and prepares for distribution
# 
# Design: Each module builds independently to source/kit*/build/
#         Central points (C/build, CPP/build) collect from modules
#         This script gathers from central points into kit-dist/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/kit-dist"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "🔧 Kit Collection & Installation Script"
echo "========================================"
echo ""

# Create distribution directory
echo "📦 Creating distribution directory: $DIST_DIR"
mkdir -p "$DIST_DIR/include"
mkdir -p "$DIST_DIR/lib"
mkdir -p "$DIST_DIR/docs"

# Counters
HEADERS_FOUND=0
LIBS_FOUND=0
MODULES_FOUND=0

echo ""
echo "📋 Gathering C module headers..."

# Gather C headers from central collection point
if [ -d "$SCRIPT_DIR/C/build/include" ]; then
    HEADER_COUNT=$(find "$SCRIPT_DIR/C/build/include" -type f -name "*.h" 2>/dev/null | wc -l)
    if [ "$HEADER_COUNT" -gt 0 ]; then
        cp "$SCRIPT_DIR/C/build/include"/*.h "$DIST_DIR/include/" 2>/dev/null || true
        HEADERS_FOUND=$((HEADERS_FOUND + HEADER_COUNT))
        echo "   ✓ C headers ($HEADER_COUNT file(s))"
        MODULES_FOUND=$((MODULES_FOUND + 1))
    else
        echo "   ⚠ C headers directory exists but is empty"
    fi
else
    echo "   ⚠ C/build/include not found (run build first)"
fi

echo ""
echo "📚 Gathering C module libraries..."

# Gather C libraries from central collection point
if [ -d "$SCRIPT_DIR/C/build/lib" ]; then
    SO_COUNT=$(find "$SCRIPT_DIR/C/build/lib" -type f -name "*.so" 2>/dev/null | wc -l)
    A_COUNT=$(find "$SCRIPT_DIR/C/build/lib" -type f -name "*.a" 2>/dev/null | wc -l)
    if [ "$SO_COUNT" -gt 0 ] || [ "$A_COUNT" -gt 0 ]; then
        cp "$SCRIPT_DIR/C/build/lib"/*.so "$DIST_DIR/lib/" 2>/dev/null || true
        cp "$SCRIPT_DIR/C/build/lib"/*.a "$DIST_DIR/lib/" 2>/dev/null || true
        LIBS_FOUND=$((LIBS_FOUND + SO_COUNT + A_COUNT))
        echo "   ✓ C libraries (.so: $SO_COUNT, .a: $A_COUNT)"
        MODULES_FOUND=$((MODULES_FOUND + 1))
    else
        echo "   ⚠ C/build/lib exists but is empty"
    fi
else
    echo "   ⚠ C/build/lib not found (run build first)"
fi

echo ""
echo "📋 Gathering C++ module headers..."

# Gather C++ headers from central collection point (if available)
if [ -d "$SCRIPT_DIR/CPP/build/include" ]; then
    HEADER_COUNT=$(find "$SCRIPT_DIR/CPP/build/include" -type f \( -name "*.hpp" -o -name "*.h" \) 2>/dev/null | wc -l)
    if [ "$HEADER_COUNT" -gt 0 ]; then
        cp "$SCRIPT_DIR/CPP/build/include"/*.hpp "$DIST_DIR/include/" 2>/dev/null || true
        cp "$SCRIPT_DIR/CPP/build/include"/*.h "$DIST_DIR/include/" 2>/dev/null || true
        HEADERS_FOUND=$((HEADERS_FOUND + HEADER_COUNT))
        echo "   ✓ C++ headers ($HEADER_COUNT file(s))"
        MODULES_FOUND=$((MODULES_FOUND + 1))
    else
        echo "   ⚠ C++ headers directory exists but is empty"
    fi
else
    echo "   ⓘ C++ not available yet (planned)"
fi

echo ""
echo "📚 Gathering C++ module libraries..."

# Gather C++ libraries from central collection point (if available)
if [ -d "$SCRIPT_DIR/CPP/build/lib" ]; then
    SO_COUNT=$(find "$SCRIPT_DIR/CPP/build/lib" -type f -name "*.so" 2>/dev/null | wc -l)
    A_COUNT=$(find "$SCRIPT_DIR/CPP/build/lib" -type f -name "*.a" 2>/dev/null | wc -l)
    if [ "$SO_COUNT" -gt 0 ] || [ "$A_COUNT" -gt 0 ]; then
        cp "$SCRIPT_DIR/CPP/build/lib"/*.so "$DIST_DIR/lib/" 2>/dev/null || true
        cp "$SCRIPT_DIR/CPP/build/lib"/*.a "$DIST_DIR/lib/" 2>/dev/null || true
        LIBS_FOUND=$((LIBS_FOUND + SO_COUNT + A_COUNT))
        echo "   ✓ C++ libraries (.so: $SO_COUNT, .a: $A_COUNT)"
        MODULES_FOUND=$((MODULES_FOUND + 1))
    else
        echo "   ⚠ C++ libraries directory exists but is empty"
    fi
else
    echo "   ⓘ C++ not available yet (planned)"
fi

# Gather documentation
echo ""
echo "📖 Gathering documentation..."

if [ -f "$SCRIPT_DIR/README.md" ]; then
    cp "$SCRIPT_DIR/README.md" "$DIST_DIR/docs/"
    echo "   ✓ Main README"
fi

if [ -f "$SCRIPT_DIR/CHANGELOG.md" ]; then
    cp "$SCRIPT_DIR/CHANGELOG.md" "$DIST_DIR/docs/"
    echo "   ✓ CHANGELOG"
fi

if [ -f "$SCRIPT_DIR/INSTALL_GUIDE.md" ]; then
    cp "$SCRIPT_DIR/INSTALL_GUIDE.md" "$DIST_DIR/docs/"
    echo "   ✓ Installation Guide"
fi

if [ -f "$SCRIPT_DIR/DISTRIBUTION_WORKFLOW.md" ]; then
    cp "$SCRIPT_DIR/DISTRIBUTION_WORKFLOW.md" "$DIST_DIR/docs/"
    echo "   ✓ Architecture Workflow"
fi

if [ -f "$SCRIPT_DIR/C/README.md" ]; then
    cp "$SCRIPT_DIR/C/README.md" "$DIST_DIR/docs/C_README.md"
    echo "   ✓ C Module README"
fi

if [ -f "$SCRIPT_DIR/CPP/README.md" ]; then
    cp "$SCRIPT_DIR/CPP/README.md" "$DIST_DIR/docs/CPP_README.md"
    echo "   ✓ C++ Module README"
fi

# Summary
echo ""
echo "========================================"
if [ "$MODULES_FOUND" -gt 0 ]; then
    echo "✅ Distribution Complete!"
else
    echo "⚠️  No modules found - build first?"
fi
echo "========================================"
echo ""
echo "📍 Location: $DIST_DIR"
echo ""

if [ "$HEADERS_FOUND" -gt 0 ] || [ "$LIBS_FOUND" -gt 0 ]; then
    echo "📦 Collected:"
    echo "   Headers: $HEADERS_FOUND file(s)"
    echo "   Libraries: $LIBS_FOUND file(s)"
    echo ""
    
    if [ -n "$(ls -A "$DIST_DIR/include/" 2>/dev/null)" ]; then
        echo "📂 Headers in kit-dist/include/:"
        ls -1 "$DIST_DIR/include/" | sed 's/^/   /'
    fi
    echo ""
    
    if [ -n "$(ls -A "$DIST_DIR/lib/" 2>/dev/null)" ]; then
        echo "📂 Libraries in kit-dist/lib/:"
        ls -lh "$DIST_DIR/lib/" | tail -n +2 | awk '{printf "   %s (%s)\n", $9, $5}'
    fi
    echo ""
fi

if [ -d "$DIST_DIR/docs" ] && [ -n "$(ls -A "$DIST_DIR/docs" 2>/dev/null)" ]; then
    echo "📚 Documentation: $(ls "$DIST_DIR/docs" | wc -l) file(s)"
    echo ""
fi

# Installation options
echo "🚀 Next Steps:"
echo ""
echo "Option 1: System Installation (requires sudo)"
echo "   sudo cp -r $DIST_DIR/include/* /usr/local/include/"
echo "   sudo cp -r $DIST_DIR/lib/* /usr/local/lib/"
echo "   sudo ldconfig"
echo ""
echo "Option 2: Local Installation (development)"
echo "   export LD_LIBRARY_PATH=$DIST_DIR/lib:\$LD_LIBRARY_PATH"
echo "   export CPATH=$DIST_DIR/include:\$CPATH"
echo ""
echo "Option 3: Custom Location"
echo "   cp -r $DIST_DIR /path/to/your/location"
echo ""
echo "Option 4: CI/CD Integration"
echo "   See INSTALL_GUIDE.md for Docker & GitHub Actions examples"
echo ""
echo "📖 For detailed instructions, see: docs/INSTALL_GUIDE.md"
echo ""
