# Quick Module Creation Reference Card

**Save this for quick lookup when creating new modules!**

---

## 30-Second Overview

```
Create source/kitXXXX/
    ↓
Write kitxxxx.d (D source with Phobos)
    ↓
Create kitxxxx.h (C header)
    ↓
Build: dub build --build=release --compiler=ldc2
    ↓
Create test.c + build.sh
    ↓
Copy to C/build/{include,lib}
    ↓
bash INSTALL.sh (automatic discovery!)
```

---

## Directory Structure Checklist

```
✓ source/kitXXXX/
  ✓ kitxxxx.d                    (D source, 50-100 lines)
  ✓ README.md                    (Module docs)
  ✓ build/
    ✓ include/
      ✓ kitxxxx.h                (C header)
    ✓ lib/
      ✓ libkitxxxx.so            (Compiled library)
    ✓ test/
      ✓ test.c                   (Test, <30 lines)
      ✓ build.sh                 (Build script)
      ✓ test                      (Executable after build)
```

---

## D Source Template (kitxxxx.d)

```d
module kitxxxx;

import std.stdio;        // Phobos features
import std.concurrency;

// C struct (must match .h)
extern (C) struct Result {
    int status;
    char[256] message;
}

// C API function
extern (C) Result kit_do_something(const char* input) {
    Result r;
    r.status = 0;
    // Use Phobos internally
    return r;
}
```

**Key rules:**
- `extern(C)` on all public functions
- C-compatible structs only
- Use Phobos internally (std.*)

---

## C Header Template (kitxxxx.h)

```c
#ifndef KITXXXX_H
#define KITXXXX_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int status;
    char message[256];
} Result;

Result kit_do_something(const char* input);

#ifdef __cplusplus
}
#endif
#endif // KITXXXX_H
```

**Key rules:**
- Include guards: `#ifndef MODULE_H`
- Match D structs exactly
- C++ compatibility wrapper

---

## Test Template (test.c)

```c
#include <kitxxxx.h>
#include <stdio.h>

int main() {
    printf("🧪 KitXXXX Test\n");
    
    Result r = kit_do_something("test");
    if (r.status == 0) {
        printf("✅ Passed\n");
        return 0;
    }
    printf("❌ Failed\n");
    return 1;
}
```

**Key rules:**
- Under 30 lines
- Use emoji for visibility
- Return 0 on success
- Use relative paths: `#include <kitxxxx.h>`

---

## Build Script Template (build.sh)

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building kitXXXX test..."
gcc \
    -I../include \
    -L../lib \
    test.c \
    -lkitxxxx \
    -Wl,-rpath,../lib \
    -o test

echo "✓ Test built successfully"
./test
```

**Key rules:**
- `-I../include` for relative header path
- `-L../lib -lkitxxxx` for library linking
- `-Wl,-rpath,../lib` for runtime linking
- `set -e` to fail on error

---

## Commands Cheat Sheet

```bash
# 1. Create module
mkdir -p kit/C/source/kitXXXX/build/{include,lib,test}

# 2. Build module
cd kit/C
dub build --build=release --compiler=ldc2

# 3. Copy to central collection
cp source/kitXXXX/build/include/kitxxxx.h build/include/
cp source/kitXXXX/build/lib/libkitxxxx.so build/lib/

# 4. Build test
bash source/kitXXXX/build/test/build.sh

# 5. Collect distribution
bash INSTALL.sh

# 6. Verify in distribution
ls -la kit-dist/include/
ls -la kit-dist/lib/
```

---

## Phobos Modules Quick Reference

| Use Case | Phobos Module | Function |
|----------|---------------|----------|
| Hashing | `std.digest.sha` | SHA-256, SHA-512 |
| HMAC | `std.digest.hmac` | Message authentication |
| Async | `std.concurrency` | Task spawning, messaging |
| Timing | `core.time` | Delays, duration |
| JSON | `std.json` | Parse/generate JSON |
| Regex | `std.regex` | Pattern matching |
| Sockets | `std.socket` | TCP/UDP networking |
| Compression | `std.zlib` | Zlib compression |
| Random | `std.random` | PRNG, secure random |
| Ranges | `std.range` | Lazy processing |

---

## Troubleshooting Quick Fixes

| Problem | Solution |
|---------|----------|
| `.so` not found | Check `source/kitXXXX/build/lib/` exists and has file |
| Test won't link | Add `-Wl,-rpath,../lib` to gcc command |
| dub build fails | Run `ldc2 --version`, ensure v1.41+, update if needed |
| Module missing from kit-dist | Verify `C/build/include/` and `C/build/lib/` have files |
| Test output unclear | Add emoji (✅ ❌ 🧪) for visibility |

---

## Full Workflow (Copy-Paste)

```bash
# Start from kit/C directory
cd /path/to/kit/C

# 1. Create structure
mkdir -p source/kitXXXX/build/{include,lib,test}

# 2. Create kitxxxx.d (paste D source template above)
# 3. Create build include/kitxxxx.h (paste C header template)
# 4. Build
dub build --build=release --compiler=ldc2

# 5. Copy library
cp source/kitXXXX/build/lib/libkitxxxx.so \
   C/build/lib/libkitxxxx.so 2>/dev/null || \
find .dub -name "libkitxxxx.so" -exec cp {} source/kitXXXX/build/lib/ \;

# 6. Create test.c (paste test template)
# 7. Create build.sh (paste build script template)
chmod +x source/kitXXXX/build/test/build.sh

# 8. Test locally
bash source/kitXXXX/build/test/build.sh

# 9. Copy to central
cp source/kitXXXX/build/include/kitxxxx.h build/include/
cp source/kitXXXX/build/lib/libkitxxxx.so build/lib/

# 10. Distribute
cd ../..
bash INSTALL.sh

# 11. Verify
ls -la kit-dist/include/kitxxxx.h
ls -la kit-dist/lib/libkitxxxx.so
```

---

## Success Checklist

Before considering module complete:

- [ ] D source compiles with `dub build --build=release`
- [ ] `.so` file exists in `source/kitXXXX/build/lib/`
- [ ] C header matches D structs exactly
- [ ] Test compiles with relative paths
- [ ] Test runs and shows ✅ or ❌
- [ ] Files copied to `C/build/{include,lib}/`
- [ ] `bash INSTALL.sh` shows new module
- [ ] Files appear in `kit-dist/`
- [ ] `README.md` documents module
- [ ] Updated `CHANGELOG.md` (optional but good practice)

---

## Pro Tips

**🔍 Debug module discovery:**
```bash
ls -la C/build/include/      # Headers collected?
ls -la C/build/lib/          # Libraries collected?
bash INSTALL.sh              # Automatic pickup
```

**📦 Portable test:**
```bash
# Move module anywhere, test still works
mv C/source/kitXXXX ~/temp/
cd ~/temp/kitXXXX/build/test
./build.sh   # Still works (relative paths)
```

**🚀 Scaling:**
- Add kitAsync, kitJSON, kitNetwork in parallel
- Each is independent
- INSTALL.sh finds them all automatically
- No script changes needed!

**📝 Documentation:**
- Keep module README under 100 lines
- Show 1-2 usage examples
- Link to full guide for details

---

## Next Steps After Module Creation

1. **Update root CHANGELOG.md** - Add module to version history
2. **Add to roadmap** - If this was planned
3. **Create examples** - Show real-world usage
4. **Benchmark** - Compare with native C libraries
5. **Document integration** - How users include this module

---

## Questions? Refer to:

- **Full guide:** `MODULE_CREATION_GUIDE.md`
- **Architecture:** `DISTRIBUTION_WORKFLOW.md`
- **Installation:** `INSTALL_GUIDE.md`
- **Working example:** `C/source/kitCrypto/`
- **Build script:** `C/INSTALL.sh`

---

**Save this file for quick reference!** Print it out or bookmark it for creating modules tomorrow. 🚀
