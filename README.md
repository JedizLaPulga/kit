# 🛠️ Kit - Modern Modular Library Architecture for C/C++ 

A powerful, modular D language library project that generates high-performance FFI bindings for **C** and **C++** using the **Phobos** standard library as a foundation. Kit compiles specialized D code with **LDC2** to produce native libraries with clean C and C++ APIs.

**New naming convention:** All modules follow the `XXXXkit` pattern (e.g., `cryptokit`, `asynckit`, `jsonkit`).

---

## 🎯 Project Overview

**Kit** bridges the gap between D's expressiveness and C/C++'s universality. We build robust, type-safe libraries in D and seamlessly expose them to C and C++ through modular, independent components:

- **Modular Design**: Each library is self-contained in `source/MODULENAMEKIT/`
- **Clean FFI Bindings**: `extern(C)` and `extern(C++)` with struct-based and object-oriented APIs
- **Cross-Platform Support**: Linux-focused development with Phobos runtime
- **Zero-Cost Abstractions**: Native performance through direct LDC2 compilation
- **Automatic Discovery**: `INSTALL.sh` automatically collects all modules

---

## 📁 Project Structure

```
Kit/
├── kit/                           # Main project directory
│   ├── C/                         # C language bindings
│   │   ├── source/
│   │   │   └── cryptokit/         # Example: Cryptography module (working)
│   │   │       ├── cryptokit.d    #   D source code
│   │   │       ├── README.md      #   Module documentation
│   │   │       └── build/
│   │   │           ├── include/cryptokit.h
│   │   │           ├── lib/libcryptokit.so
│   │   │           └── test/test.c
│   │   ├── build/                 # Central collection directory
│   │   │   ├── include/cryptokit.h
│   │   │   └── lib/libcryptokit.so
│   │   ├── dub.json               # Dub configuration for C
│   │   └── README.md              # C binding documentation
│   ├── CPP/                       # C++ language bindings
│   │   ├── source/                # D source files for C++ interop
│   │   ├── dub.json               # Dub configuration for C++
│   │   └── README.md              # C++ binding documentation
│   ├── kit-dist/                  # Distribution package
│   │   ├── include/               # Collected headers
│   │   ├── lib/                   # Collected libraries
│   │   └── docs/                  # Documentation
│   ├── INSTALL.sh                 # Automatic module collection script
│   ├── MODULE_CREATION_GUIDE.md   # Guide for creating new modules
│   ├── QUICK_MODULE_REFERENCE.md  # Quick reference card
│   └── README.md                  # This file
└── LICENSE                         # License information
```

---

## ⚡ Quick Start - Use Kit in 60 Seconds

### 1. Build & Install

```bash
# Clone and build
git clone https://github.com/your-org/kit.git && cd kit/kit/C
dub build --build=release --compiler=ldc2

# Collect all modules
cd ../..
bash INSTALL.sh

# Install system-wide
sudo cp -r kit-dist/include/* /usr/local/include/
sudo cp -r kit-dist/lib/* /usr/local/lib/
sudo ldconfig
```

### 2. Use CryptoKit in Your C Code

```c
#include <cryptokit.h>
#include <stdio.h>
#include <string.h>

int main() {
    const char* message = "Hello, Kit!";
    
    // Compute SHA-256 hash
    SHA256Hash hash = kit_sha256(message, strlen(message));
    
    printf("SHA-256: ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", hash.hash[i]);
    }
    printf("\n");
    
    return 0;
}
```

### 3. Compile & Run

```bash
gcc main.c -lcryptokit -o app && ./app
```

✅ **Done!** Zero dependencies, cryptography in just 3 lines of code.

---

## 🚀 Getting Started

### Prerequisites

- **LDC2** (LLVM D Compiler) v1.41+ - [Install LDC2](https://github.com/ldc-developers/ldc)
- **Dub** - D package manager (bundled with LDC2)
- **Linux** (primary target environment)
- Standard C/C++ development tools (gcc/g++, make, etc.)

### Building from Source

#### Option 1: Build C Library with All Modules

```bash
cd kit/kit/C
dub build --build=release --compiler=ldc2
```

#### Option 2: Build Specific Module Only

```bash
# Build just CryptoKit
cd kit/kit/C/source/cryptokit
dub build --build=release --compiler=ldc2
```

#### Option 3: Collect Distribution

```bash
cd kit/kit
bash INSTALL.sh
# Creates kit-dist/ with all modules collected
```

---

## 📦 Available Modules

### ✅ CryptoKit (Cryptography) - Working Module

Cryptographic primitives powered by Phobos `std.digest`, available in both **C** and **C++**.

**Features:**
- SHA-256 hashing
- HMAC-SHA256 message authentication
- Timing-attack resistant constant-time operations
- Phobos-based, battle-tested algorithms
- Streaming support for large data processing
- RAII semantics in C++ version

**Available for:**
- **C** (`extern(C)`) - Function-based API
- **C++** (`extern(C++)`) - ABI-compatible, opaque pointer classes with value types

**C Usage Example:**
```c
#include <cryptokit.h>

// SHA-256
SHA256Hash hash = kit_sha256(data, length);

// HMAC-SHA256
HMACResult hmac = kit_hmac_sha256(data, data_len, key, key_len);
```

**C++ Usage Example:**
```cpp
#include "cryptokitpp.hpp"

using namespace kit;

// One-shot hash
SHA256Hash hash = kit_sha256("hello", 5);
std::string hex = hash.toHexString();

// Streaming hash
SHA256Hasher* hasher = kit_create_sha256_hasher();
kit_sha256_hasher_update(hasher, "part1", 5);
kit_sha256_hasher_update(hasher, "part2", 5);
SHA256Hash result = kit_sha256_hasher_finish(hasher);
```

**Location:** 
- C: `C/source/cryptokit/`
- C++: `CPP/source/cryptokit/`

**More info:** 
- [CryptoKit C README](./C/source/cryptokit/README.md)
- [CryptoKit C++ README](./CPP/source/cryptokit/README.md)

---

### 📋 Planned Modules

The following modules are planned and follow the new `XXXXkit` naming:

| Module | Purpose | Status |
|--------|---------|--------|
| **cryptokit** | Cryptographic primitives (SHA-256, HMAC) | ✅ **Working** (C & C++) |
| **asynckit** | Async task scheduling, concurrency primitives | 📋 Planned |
| **jsonkit** | JSON parsing and generation | 📋 Planned |
| **networkkit** | TCP/UDP sockets, HTTP client/server | 📋 Planned |

---

## 🎓 Real-World Examples

### Example 1: Cryptographic Hashing with CryptoKit

**File:** `main.c`

```c
#include <cryptokit.h>
#include <stdio.h>
#include <string.h>

int main() {
    // Generate HMAC-SHA256 for API authentication
    const char* key = "your-secret-key";
    const char* message = "user_id=42&action=purchase";
    
    // Compute HMAC
    HMACResult hmac = kit_hmac_sha256(
        message, strlen(message),
        key, strlen(key)
    );
    
    // Print result
    printf("API Signature: ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", hmac.digest[i]);
    }
    printf("\n");
    
    return 0;
}
```

**Compile & Run:**
```bash
gcc main.c -lcryptokit -o app
./app
```

✨ *Cryptographic primitives built-in—no external dependencies, constant-time operations prevent timing attacks.*

---

### Example 2: Creating a New Module (AsyncKit Pattern)

This demonstrates how to create a new module following the Kit conventions.

**Step 1: Create Directory Structure**
```bash
cd kit/kit/C/source
mkdir -p asynckit/build/{include,lib,test}
cd asynckit
```

**Step 2: Write D Source (asynckit.d)**
```d
module asynckit.asynckit;

import std.concurrency;
import std.stdio;

extern(C):

struct TaskResult {
    int status;
    int result;
}

TaskResult kit_spawn_task(int value) {
    TaskResult res;
    res.status = 0;
    res.result = value * 2;
    return res;
}
```

**Step 3: Create C Header (build/include/asynckit.h)**
```c
#ifndef ASYNCKIT_H
#define ASYNCKIT_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int status;
    int result;
} TaskResult;

TaskResult kit_spawn_task(int value);

#ifdef __cplusplus
}
#endif
#endif // ASYNCKIT_H
```

**Step 4: Create Test (build/test/test.c)**
```c
#include <asynckit.h>
#include <stdio.h>

int main() {
    printf("🧪 AsyncKit Module Test\n");
    
    TaskResult result = kit_spawn_task(21);
    printf("Result: %d\n", result.result);
    
    printf("✅ AsyncKit tests passed!\n");
    return 0;
}
```

**Step 5: Build & Test**
```bash
# From kit/C directory
dub build --build=release --compiler=ldc2

# Test
bash source/asynckit/build/test/build.sh

# Collect to central directory
cp source/asynckit/build/include/asynckit.h build/include/
cp source/asynckit/build/lib/libasynckit.so build/lib/

# Generate distribution
bash INSTALL.sh
```

✨ *New modules are automatically discovered by INSTALL.sh!*

---

## 🎯 Key Benefits

🚀 **Modular Architecture** — Each library is independent, develop/test/deploy separately

🎯 **Zero Configuration** — Just include headers and link—no complex build setup

📦 **Production-Ready** — Battle-tested algorithms (Phobos), optimized by LDC2

✨ **Modern APIs** — Clean C/C++ interfaces that feel natural to use

🔗 **No External Dependencies** — Cryptography, async, JSON, networking all built-in

🛡️ **Secure by Default** — Cryptographic operations use constant-time implementations

📈 **Easy to Extend** — New modules follow simple, consistent patterns

---

## 🌟 Module Naming Convention

All Kit modules follow a consistent naming pattern:

```
Directory:  source/MODULENAMEKIT/
D Source:   modulenamekit.d
C Header:   modulenamekit.h
Library:    libmodulenamekit.so
Module:     modulenamekit (D module)
```

**Examples:**
- CryptoKit: `source/cryptokit/`, `cryptokit.d`, `libcryptokit.so`
- AsyncKit: `source/asynckit/`, `asynckit.d`, `libasynckit.so`
- JSONKit: `source/jsonkit/`, `jsonkit.d`, `libjsonkit.so`
- NetworkKit: `source/networkkit/`, `networkkit.d`, `libnetworkkit.so`

This convention ensures consistency across all modules and makes it easy to discover and understand the codebase.

---

## 🔧 Integration Guide

### Using CryptoKit in Your C Project

```bash
# 1. Build Kit
cd kit/kit/C
dub build --build=release --compiler=ldc2

# 2. Copy headers and libraries to your project
cp build/include/cryptokit.h /path/to/your/project/
cp build/lib/libcryptokit.so /path/to/your/project/

# 3. Link in your project
gcc main.c \
    -I./build/include \
    -L./build/lib \
    -lcryptokit \
    -Wl,-rpath,./build/lib \
    -o app
./app
```

### System-Wide Installation

```bash
# From kit/kit directory
bash INSTALL.sh

# Install to system
sudo cp -r kit-dist/include/* /usr/local/include/
sudo cp -r kit-dist/lib/* /usr/local/lib/
sudo ldconfig

# Now use from anywhere
gcc main.c -lcryptokit -o app
```

### Custom Installation Path

```bash
# From kit/kit directory
bash INSTALL.sh
cp -r kit-dist /opt/kit-libraries

# Set environment variables
export LD_LIBRARY_PATH=/opt/kit-libraries/lib:$LD_LIBRARY_PATH
export CPATH=/opt/kit-libraries/include:$CPATH

# Compile
gcc main.c -lcryptokit -o app
```

---

## 📊 Module Comparison

| Feature | Manual C | External Libs | **Kit Modules** |
|---------|----------|--------------|-----------------|
| **Setup Time** | Days | Days | Minutes |
| **Dependencies** | External | External | None—modular `.so` |
| **Performance** | Good | Good | **Optimized by LDC2** ⚡ |
| **API Quality** | Varies | Varies | **Consistent, modern** |
| **Maintenance** | Yours | Community | **Active development** |
| **Extension** | Manual | Manual | **Standardized pattern** |

---

## 📖 Documentation

Each subdirectory contains detailed documentation:

- **[C Library Documentation](./C/README.md)** - C binding patterns, all available modules
- **[CryptoKit Module](./C/source/cryptokit/README.md)** - Cryptography API reference
- **[Module Creation Guide](./MODULE_CREATION_GUIDE.md)** - Complete walkthrough for creating new modules
- **[Quick Module Reference](./QUICK_MODULE_REFERENCE.md)** - Quick reference card for new modules
- **[Installation & Distribution](./INSTALL_GUIDE.md)** - 4 installation methods and CI/CD
- **[Architecture Workflow](./DISTRIBUTION_WORKFLOW.md)** - Design decisions and module organization
- **[Changelog](./CHANGELOG.md)** - Version history and release notes

---

## 🤝 Contributing

We welcome contributions! Areas of interest:

- **New Phobos-powered modules** — Follow the `XXXXkit` naming convention
- **Performance optimizations** — Benchmark and improve existing modules
- **Binding examples** — Real-world usage demonstrations
- **Documentation improvements** — Better guides and tutorials
- **Bug reports and fixes** — Help us improve stability

**Getting started:**
1. Read [Module Creation Guide](./MODULE_CREATION_GUIDE.md)
2. Use [Quick Module Reference](./QUICK_MODULE_REFERENCE.md)
3. Follow the naming convention: `XXXXkit`
4. Test thoroughly with included test framework

---

## 📄 License

Please see LICENSE file in the repository root for licensing information.

---

## 🔗 Useful Resources

- [LDC2 Documentation](https://wiki.dlang.org/LDC)
- [D Language Reference](https://dlang.org/spec/spec.html)
- [Phobos Standard Library](https://dlang.org/phobos/)
  - [std.digest](https://dlang.org/phobos/std_digest.html) - Cryptography (used in cryptokit)
  - [std.concurrency](https://dlang.org/phobos/std_concurrency.html) - Async & channels
  - [std.json](https://dlang.org/phobos/std_json.html) - JSON parsing
  - [std.regex](https://dlang.org/phobos/std_regex.html) - Pattern matching
  - [std.socket](https://dlang.org/phobos/std_socket.html) - Networking
- [Dub Package Manager](https://dub.pm/)
- [D FFI Guide](https://dlang.org/spec/interfaceToC.html)
- [C++ Interop in D](https://dlang.org/spec/cpp_interface.html)

---

## 🚀 Roadmap

### ✅ Completed
- [x] CryptoKit module (SHA-256, HMAC-SHA256)
- [x] Modular architecture with automatic discovery
- [x] C FFI bindings
- [x] Module testing framework
- [x] Documentation and guides

### 📋 Planned
- [ ] AsyncKit - Task scheduling and concurrency
- [ ] JSONKit - JSON parsing and generation
- [ ] NetworkKit - Networking primitives
- [ ] Performance benchmarks
- [ ] Additional crypto functions (SHA-512, Blake2)

---

**Built with ❤️ using D Language | Powered by Phobos and LDC2**
