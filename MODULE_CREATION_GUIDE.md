# Module Creation Guide

A complete walkthrough for creating new Kit modules. Use this guide to add modules like **kitAsync**, **kitJSON**, **kitNetwork**, etc.

---

## Overview: Module Architecture

Each Kit module follows a **modular, self-contained design**:

```
Language Layer (C or CPP)
    ↓
C or CPP/
    ├── source/kitXXXX/
    │   ├── kitxxxx.d                    ← D source code
    │   ├── README.md                    ← Module documentation
    │   └── build/                       ← Self-contained build output
    │       ├── include/kitxxxx.h(pp)
    │       ├── lib/libkitxxxx.so
    │       └── test/test.c(pp) + test   ← Portable tests
    │
    └── build/                           ← Central collection
        ├── include/kitxxxx.h(pp)
        └── lib/libkitxxxx.so
        
        ↓ INSTALL.sh gathers these
        
kit-dist/                               ← Distribution
    ├── include/kitxxxx.h(pp)
    ├── lib/libkitxxxx.so
    └── docs/
```

**Key principles:**
- Each module under 'source' is **independent** and **portable**
- Module owns its `source/kitXXXX/build/` for development
- Central `C/build/` or `CPP/build/` mirrors module outputs for distribution
- Tests use **relative paths** (`../include`, `../lib`) for portability
- **INSTALL.sh** automatically discovers and collects all modules

---

## Quick Reference: Creating a New Module

Here's the high-level process (detailed steps follow):

```bash
# 1. Create module structure
cd kit/C
mkdir -p source/kitAsync
touch source/kitAsync/kitasync.d
touch source/kitAsync/README.md

# 2. Write D implementation
# - Add extern(C) functions
# - Use Phobos features

# 3. Build with Dub
dub build --build=release --compiler=ldc2

# 4. Create C header
# - Define structs
# - Declare extern(C) functions

# 5. Copy to module build/
mkdir -p source/kitAsync/build/{include,lib,test}
cp C/build/include/kitasync.h source/kitAsync/build/include/
cp C/build/lib/libkitasync.so source/kitAsync/build/lib/

# 6. Write test.c
# - Use relative paths
# - Keep <30 lines

# 7. Test
cd source/kitAsync/build/test
./test

# 8. Run INSTALL.sh
# - Automatically picks up your module!
cd ../../..
bash INSTALL.sh
```

---

## Step-by-Step: Creating kitAsync (Example)

A complete worked example for an async task module.

### Step 1: Create Directory Structure

```bash
cd /home/hp/Documents/github/Kit/kit/C
mkdir -p source/kitAsync/build/{include,lib,test}
```

### Step 2: Create D Source File

**File:** `source/kitAsync/kitasync.d`

```d
module kitasync;

import std.concurrency : spawn, thisTid, send, receiveOnly;
import std.stdio : writeln;
import core.time : dur;

// C struct representing a task
extern (C) struct TaskHandle {
    ulong id;
}

// C struct for task result
extern (C) struct TaskResult {
    ulong task_id;
    int status;        // 0 = success, 1 = error
    char[256] message; // Result message
}

// Global task counter
shared ulong task_counter = 0;

// C API: Create and run an async task
// Returns a task handle
extern (C) TaskHandle kit_create_task(
    const char* task_name,
    int delay_ms
) {
    import core.atomic : atomicOp;
    
    ulong id = atomicOp!"+="(task_counter, 1);
    
    TaskHandle handle;
    handle.id = id;
    
    // In real implementation, spawn actual task
    // For now, just return handle
    return handle;
}

// C API: Wait for task completion
extern (C) TaskResult kit_wait_task(TaskHandle handle) {
    TaskResult result;
    result.task_id = handle.id;
    result.status = 0;
    
    // Simple result for demo
    import std.string : toStringz;
    import std.c.string : strcpy;
    strcpy(result.message.ptr, cast(char*)"Task completed".ptr);
    
    return result;
}
```

**Key points:**
- Use `extern (C)` for all public functions
- Define C-compatible structs (no D-specific features)
- Use Phobos `std.concurrency` for async logic
- Keep function signatures simple

### Step 3: Create C Header File

**File:** `source/kitAsync/build/include/kitasync.h`

```c
#ifndef KITASYNC_H
#define KITASYNC_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Task handle (opaque reference)
typedef struct {
    uint64_t id;
} TaskHandle;

// Task result
typedef struct {
    uint64_t task_id;
    int status;              // 0 = success, 1 = error
    char message[256];       // Result message
} TaskResult;

// Create and run an async task
// Parameters:
//   task_name: Name/description of task
//   delay_ms: Delay in milliseconds before execution
// Returns: TaskHandle for tracking
TaskHandle kit_create_task(const char* task_name, int delay_ms);

// Wait for task completion
// Parameters:
//   handle: TaskHandle from kit_create_task()
// Returns: TaskResult with status and message
TaskResult kit_wait_task(TaskHandle handle);

#ifdef __cplusplus
}
#endif

#endif // KITASYNC_H
```

**Header requirements:**
- Include guards: `#ifndef MODULE_H`
- Use standard C types (`uint64_t`, not `ulong`)
- Document parameters and returns
- C++ compatibility wrapper (`extern "C"`)

### Step 4: Create Module README

**File:** `source/kitAsync/README.md`

```markdown
# KitAsync: Asynchronous Task Module

Phobos-powered async task execution for C.

## Features

- Lightweight task spawning
- Delay scheduling
- Task status tracking
- Built on `std.concurrency`

## Quick Start

Build:
```bash
cd ../..
dub build --build=release --compiler=ldc2
```

Test:
```bash
cd source/kitAsync/build/test
./test
```

## API Reference

### kit_create_task
Create and schedule an async task.

```c
TaskHandle handle = kit_create_task("my_task", 1000);  // 1 second delay
```

### kit_wait_task
Wait for task completion.

```c
TaskResult result = kit_wait_task(handle);
if (result.status == 0) {
    printf("Success: %s\n", result.message);
}
```

## Examples

See `build/test/test.c` for usage examples.

## Implementation Details

Built with Phobos `std.concurrency` for:
- Thread-safe task spawning
- Message passing between tasks
- Non-blocking async operations
```

### Step 5: Build with Dub

```bash
cd /home/hp/Documents/github/Kit/kit/C
dub build --build=release --compiler=ldc2
```

Output:
```
Building kit-c 0.0.1-master...
Compiling source/kitCrypto/kitcrypto.d ...
Compiling source/kitAsync/kitasync.d ...
Linking libkitcrypto.so ...
Linking libkitasync.so ...
Build complete: 2 modules
```

### Step 6: Copy Outputs to Module Build

The build produces libraries in `C/.dub/build/`. Copy them:

```bash
# Copy kitAsync header (create if doesn't exist)
cp source/kitAsync/build/include/kitasync.h \
   build/include/kitasync.h

# Copy kitAsync library from dub build
find C/.dub/build -name "libkitasync.so" -exec \
  cp {} source/kitAsync/build/lib/ \;

# Or if using Dub with custom naming
# (depends on your dub.json configuration)
```

**Better approach:** Modify `dub.json` to generate libraries directly to `source/kitXXXX/build/lib/`:

```json
{
  "name": "kit-c",
  "targetType": "dynamicLibrary",
  "configurations": [
    {
      "name": "kitcrypto",
      "mainSourceFile": "source/kitCrypto/kitcrypto.d",
      "targetName": "kitcrypto",
      "postBuildCommands": [
        "cp C/.dub/build/*/libkitcrypto.so source/kitCrypto/build/lib/ || true"
      ]
    },
    {
      "name": "kitasync",
      "mainSourceFile": "source/kitAsync/kitasync.d",
      "targetName": "kitasync",
      "postBuildCommands": [
        "cp C/.dub/build/*/libkitasync.so source/kitAsync/build/lib/ || true"
      ]
    }
  ]
}
```

Then build specific module:
```bash
dub build --config=kitasync --build=release --compiler=ldc2
```

### Step 7: Create Test

**File:** `source/kitAsync/build/test/test.c`

Keep it simple and self-contained (< 30 lines):

```c
#include <kitasync.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("🧪 KitAsync Module Test\n");
    printf("=======================\n\n");
    
    // Create a task
    TaskHandle task = kit_create_task("test_task", 500);
    printf("Created task with ID: %lu\n", task.id);
    
    // Wait for completion
    TaskResult result = kit_wait_task(task);
    printf("Task result: status=%d, message=%s\n", result.status, result.message);
    
    if (result.status == 0) {
        printf("\n✅ KitAsync tests passed!\n");
        return 0;
    } else {
        printf("\n❌ KitAsync tests failed!\n");
        return 1;
    }
}
```

**Test requirements:**
- Use only relative paths: `#include <kitasync.h>`
- Link with `-L../lib -lkitasync`
- Use `-Wl,-rpath,../lib` for runtime linking
- Keep output simple (emoji + message)
- Return 0 on success, non-zero on failure

### Step 8: Create Test Build Script

**File:** `source/kitAsync/build/test/build.sh`

```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building kitAsync test..."
gcc -v \
    -I../include \
    -L../lib \
    test.c \
    -lkitasync \
    -Wl,-rpath,../lib \
    -o test

echo "✓ Test built successfully"
echo ""
echo "Running test..."
./test
```

Make it executable:
```bash
chmod +x source/kitAsync/build/test/build.sh
```

Run:
```bash
bash source/kitAsync/build/test/build.sh
```

### Step 9: Update Central Collection

The central `C/build/` should mirror the module build:

```bash
# After module build, copy to central location
cp source/kitAsync/build/include/kitasync.h build/include/
cp source/kitAsync/build/lib/libkitasync.so build/lib/
```

### Step 10: Test INSTALL.sh

Run the collection script:

```bash
bash INSTALL.sh
```

Expected output:
```
🔧 Kit Collection & Installation Script
========================================

📦 Creating distribution directory...
📋 Gathering C module headers...
   ✓ C headers (2 file(s))      ← kitcrypto.h + kitasync.h

📚 Gathering C module libraries...
   ✓ C libraries (.so: 2, .a: 0) ← libkitcrypto.so + libkitasync.so

📂 Headers in kit-dist/include/:
   kitcrypto.h
   kitasync.h

📂 Libraries in kit-dist/lib/:
   libkitcrypto.so (18K)
   libkitasync.so (22K)

✅ Distribution Complete!
```

**INSTALL.sh automatically picks up your module!** No changes needed.

---

## Checklist: Creating a New Module

Use this checklist when adding a new module:

- [ ] Create `source/kitXXXX/` directory
- [ ] Write `source/kitXXXX/kitxxxx.d` with:
  - [ ] Phobos imports and logic
  - [ ] C-compatible structs
  - [ ] `extern(C)` functions
- [ ] Create `source/kitXXXX/build/{include,lib,test}/` directories
- [ ] Create `source/kitXXXX/build/include/kitxxxx.h` with:
  - [ ] Include guards
  - [ ] Struct definitions matching D code
  - [ ] Function declarations
  - [ ] Documentation comments
- [ ] Create `source/kitXXXX/README.md` with:
  - [ ] Features overview
  - [ ] Quick start
  - [ ] API reference
  - [ ] Implementation notes
- [ ] Update `dub.json` to build your module
- [ ] Build: `dub build --build=release --compiler=ldc2`
- [ ] Copy outputs to `source/kitXXXX/build/{include,lib}/`
- [ ] Create `source/kitXXXX/build/test/test.c` (<30 lines)
- [ ] Create `source/kitXXXX/build/test/build.sh` script
- [ ] Test locally: `bash source/kitXXXX/build/test/build.sh`
- [ ] Copy to central: `C/build/{include,lib}/`
- [ ] Run `bash INSTALL.sh` to verify integration
- [ ] Update `CHANGELOG.md` with new module

---

## Module Templates

### Minimal Module Template

**File structure:**
```
source/kitXXXX/
├── kitxxxx.d                        (50-100 lines)
├── README.md                        (50-100 lines)
└── build/
    ├── include/kitxxxx.h            (auto-generated/manual)
    ├── lib/libkitxxxx.so            (compiled)
    └── test/
        ├── test.c                   (20-30 lines)
        └── build.sh                 (10 lines)
```

**D source template:**
```d
module kitxxxx;

import std.stdio;
import std.string;

extern (C) struct Result {
    int status;
    char[256] message;
}

extern (C) Result kit_do_something(const char* input) {
    Result r;
    r.status = 0;
    // Implementation using Phobos
    return r;
}
```

**C header template:**
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
#endif
```

**Test template:**
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

---

## Phobos Features by Use Case

Here's what you can expose from Phobos for different modules:

### Crypto Module (kitCrypto) ✓ Done
- `std.digest.sha` - SHA-256, SHA-512
- `std.digest.hmac` - HMAC authentication
- `std.digest.blake2` - Blake2 hashing

### Async Module (kitAsync) - Recommended Next
- `std.concurrency` - Task spawning, message passing
- `core.time` - Delay/timing
- `std.parallelism` - Parallel maps/reductions

### JSON Module (kitJSON) - Popular
- `std.json` - Parse/generate JSON
- `std.conv` - Type conversions
- `std.range` - Processing streams

### Network Module (kitNetwork) - Advanced
- `std.socket` - TCP/UDP sockets
- `std.net.curl` - HTTP requests
- `std.socket` - DNS queries

---

## Troubleshooting

### "Cannot find libkitxxxx.so" in test

**Problem:** Test can't link to library.

**Solution:** Ensure:
1. `dub build` completed successfully
2. `.so` file exists in `source/kitXXXX/build/lib/`
3. Test uses `-L../lib -lkitxxxx`
4. Test uses `-Wl,-rpath,../lib` for runtime linking

```bash
# Debug: Check library exists
ls -la source/kitXXXX/build/lib/

# Debug: Check linker path
gcc -L../lib -lkitxxxx test.c -v
```

### "Module not appearing in INSTALL.sh output"

**Problem:** New module missing from distribution.

**Solution:** 
1. Verify `C/build/include/kitxxxx.h` exists
2. Verify `C/build/lib/libkitxxxx.so` exists
3. Run `bash INSTALL.sh` again
4. Check `kit-dist/` output

### "dub build fails with undefined symbol"

**Problem:** Phobos function not found.

**Solution:**
1. Ensure you imported the module: `import std.xxx;`
2. Check LDC2 version: `ldc2 --version`
3. Try upgrading: `curl https://dlang.org/install.sh | bash -s ldc`

---

## Best Practices

### Code Style

```d
// ✓ Good: Clear, documented
extern (C) Result kit_compute(const ubyte* data, size_t length) {
    // Use Phobos types internally
    ubyte[] input = data[0..length];
    auto processed = performPhobosLogic(input);
    // Return C-compatible result
    return toResult(processed);
}

// ✗ Bad: Undocumented, complex
extern (C) Result kit_compute(const ubyte* data, size_t length) {
    return Result(complexNativeCode(data, length));
}
```

### Testing

```bash
# ✓ Good: Relative paths, portable
gcc test.c -I../include -L../lib -lkitxxx -Wl,-rpath,../lib

# ✗ Bad: Absolute paths, not portable
gcc test.c -I/home/user/kit/include -L/home/user/kit/lib
```

### Documentation

```c
// ✓ Good: Clear contracts
/// Compute hash of input data
/// @param data Buffer to hash (non-null)
/// @param length Buffer length in bytes
/// @return Hash result with computed hash
Result kit_hash(const unsigned char* data, size_t length);

// ✗ Bad: Vague
Result kit_hash(const unsigned char* data, size_t length);
```

---

## Integration with INSTALL.sh

**How it works:**

1. INSTALL.sh looks for `C/build/include/*.h` and `C/build/lib/*.so`
2. For each file found, copies to `kit-dist/include/` and `kit-dist/lib/`
3. INSTALL.sh **automatically scales** as you add modules
4. No script changes needed—just follow the directory structure

**To add your module to distribution:**

```bash
# 1. Build your module
dub build --config=kitasync --build=release --compiler=ldc2

# 2. Copy to central collection
cp source/kitAsync/build/include/kitasync.h build/include/
cp source/kitAsync/build/lib/libkitasync.so build/lib/

# 3. Run INSTALL.sh (automatic discovery!)
bash INSTALL.sh
```

That's it! INSTALL.sh will find your module automatically.

---

## Next Module Ideas

Ready to create more modules? Here are good candidates:

1. **kitAsync** - Task spawning, delays, message passing
2. **kitJSON** - JSON parsing and generation
3. **kitNetwork** - TCP/UDP sockets, HTTP
4. **kitRandom** - Cryptographically secure random numbers
5. **kitRegex** - Pattern matching using Phobos regex
6. **kitCompress** - Zlib/LZMA compression via Phobos

Each follows the same pattern—just pick Phobos features and expose them via extern(C).

---

## Questions?

Refer back to these files for examples:
- **Working module:** `C/source/kitCrypto/`
- **Build script:** `C/INSTALL.sh`
- **Full architecture:** `DISTRIBUTION_WORKFLOW.md`

Happy building! 🚀
