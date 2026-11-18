# Kit-C: Cryptographic Library for C

High-performance cryptographic library using **Phobos** and **D Language**, compiled to native C bindings with LDC2.

## Overview

Kit-C provides battle-tested cryptographic functions via Phobos `std.digest`, exposed as clean C FFI bindings. No external dependencies—everything is built-in and optimized.

```
D Source (cryptokit.d)
    ↓ LDC2 Compiler
    ↓
libcryptokit.so + cryptokit.h
    ↓
Use from C programs
```

## Current Features

### Cryptography (Phobos-Powered)

✅ **SHA-256 Hashing**
- Fast, secure hash function
- Streaming support for large data
- `kit_sha256(data, length)`

✅ **HMAC-SHA256**
- Message authentication codes
- API signature verification
- Constant-time comparison (timing-attack resistant)
- `kit_hmac_sha256(data, data_len, key, key_len)`

## Project Structure

```
kit/C/
├── source/
│   └── cryptokit/
│       ├── README.md                    ← Module documentation
│       ├── cryptokit.d                  ← D source code
│       └── build/
│           ├── include/cryptokit.h
│           ├── lib/libcryptokit.so
│           └── test/test                ✓ Verified working
│
├── build/                               ← Central collection
│   ├── include/cryptokit.h
│   └── lib/libcryptokit.so
│
├── dub.json                             ← Build configuration
├── INSTALL.sh                           ← Collection script (at kit/ root)
├── CHANGELOG.md                         ← Version history
└── README.md                            ← This file
```

## Quick Start

### Build

```bash
# From kit/C directory
dub build --build=release --compiler=ldc2
```

### Test

```bash
cd source/cryptokit/build/test
./test
```

**Expected output:**
```
🧪 CryptoKit Module Test
========================

SHA-256: b67d1b3ab0d839eb8bc1156b8717bb441c897fcab323374e2ae530a40632feba
HMAC: 1c061a9f9652e803b8ca3fc972e023f8d43136380e7542d829e7980deacd6b94

✅ CryptoKit tests passed!
```

## Usage in C

### Simple Example

```c
#include <cryptokit.h>
#include <stdio.h>
#include <string.h>

int main() {
    const char* message = "Hello, Kit!";
    
    // Compute SHA-256
    SHA256Hash hash = kit_sha256(message, strlen(message));
    
    printf("SHA-256: ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", hash.hash[i]);
    }
    printf("\n");
    
    return 0;
}
```

### Compile & Link

```bash
gcc myapp.c \
  -I./source/cryptokit/build/include \
  -L./source/cryptokit/build/lib \
  -lcryptokit \
  -Wl,-rpath,./source/cryptokit/build/lib \
  -o myapp

./myapp
```

## Modules

### CryptoKit

Cryptographic primitives via Phobos `std.digest`.

- **Location:** `source/cryptokit/`
- **Header:** `build/include/cryptokit.h`
- **Library:** `build/lib/libcryptokit.so`
- **Functions:**
  - `kit_sha256()` - SHA-256 hashing
  - `kit_hmac_sha256()` - HMAC authentication
- **Status:** ✅ Fully functional, tested

See [CryptoKit/README.md](./source/cryptokit/README.md) for detailed documentation.

## Architecture

### Modular Design

Each module is **self-contained** with its own build output:

```
source/cryptokit/build/
  ├── include/     ← Headers for this module
  ├── lib/         ← Libraries for this module
  └── test/        ← Tests for this module
```

**Benefits:**
- Independent development and testing
- Portable (move module anywhere)
- Clear dependencies
- Easy to add more modules

### Central Collection

All module outputs collected to `build/` for easy discovery:

```bash
# All outputs at one level
kit/C/build/
  ├── include/cryptokit.h
  └── lib/libcryptokit.so
```

**Used by:**
- Distribution scripts (`INSTALL.sh`)
- System installation
- CI/CD pipelines

## Installation Options

### Option 1: Local Development

```bash
# Already available in source/cryptokit/build/
gcc myapp.c -I./source/cryptokit/build/include \
            -L./source/cryptokit/build/lib \
            -lcryptokit -o myapp
```

### Option 2: System Installation

```bash
# From kit/ root directory
bash INSTALL.sh

sudo cp -r kit-dist/include/* /usr/local/include/
sudo cp -r kit-dist/lib/* /usr/local/lib/
sudo ldconfig

# Then use anywhere
gcc myapp.c -lcryptokit -o myapp
```

### Option 3: Custom Location

```bash
# From kit/ root directory
bash INSTALL.sh

cp -r kit-dist /opt/kit-libraries
export LD_LIBRARY_PATH=/opt/kit-libraries/lib:$LD_LIBRARY_PATH
export CPATH=/opt/kit-libraries/include:$CPATH

gcc myapp.c -lcryptokit -o myapp
```

## Building

### Prerequisites

- **LDC2** (LLVM D Compiler) v1.41+
- **Dub** (D package manager, bundled with LDC2)
- **GCC** or Clang (for compiling C code)
- **Linux** (primary target)

### Build Configuration

Edit `dub.json` to customize:

```json
{
  "name": "kit-c",
  "targetType": "dynamicLibrary",
  "targetName": "kit",
  "compiler": "ldc2"
}
```

### Build Variants

```bash
# Debug build
dub build

# Release build (optimized)
dub build --build=release --compiler=ldc2

# Clean rebuild
dub clean
dub build --build=release --compiler=ldc2
```

## Testing

### Run Module Tests

```bash
cd source/cryptokit/build/test
./test
```

### Test Your Own Code

```bash
# Compile with debug symbols
gcc -g myapp.c -I./source/cryptokit/build/include \
            -L./source/cryptokit/build/lib \
            -lcryptokit -o myapp_debug

# Run with debugger
gdb ./myapp_debug
```

## Troubleshooting

### "libcryptokit.so: cannot open shared object file"

**Solution:** Use `-Wl,-rpath` when linking:

```bash
gcc myapp.c -L./source/cryptokit/build/lib \
            -lcryptokit \
            -Wl,-rpath,./source/cryptokit/build/lib \
            -o myapp
```

### Build fails with "compiler not found"

**Solution:** Install LDC2:

```bash
curl https://dlang.org/install.sh | bash -s ldc
source ~/dlang/ldc-*/activate
```

## Performance

Compiled with LDC2 optimization flags:
- **Release builds** use `-O3` optimization
- **Native code** - no JIT or interpreter overhead
- **Phobos foundation** - battle-tested algorithms
- **Zero-copy** where possible

## Roadmap

### Completed ✅
- [x] SHA-256 hashing
- [x] HMAC-SHA256 authentication
- [x] C FFI bindings
- [x] Module testing
- [x] Documentation

### Planned 📋
- [ ] SHA-512 hashing
- [ ] Blake2 hashing
- [ ] Password hashing (Argon2, Bcrypt)
- [ ] RSA signatures
- [ ] AES encryption

## Contributing

Contributions welcome! Areas of interest:

- Additional crypto functions
- Performance optimizations
- Bug reports and fixes
- Documentation improvements
- Example code

## License

See [LICENSE](../../LICENSE) file in Kit root directory.

## Resources

- [Phobos std.digest](https://dlang.org/phobos/std_digest.html)
- [D Language Reference](https://dlang.org/spec/spec.html)
- [LDC2 Documentation](https://wiki.dlang.org/LDC)
- [Kit Project](../) - Parent project documentation

---

**Powered by Phobos & D Language | Built with LDC2**
