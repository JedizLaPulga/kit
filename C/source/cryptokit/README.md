# CryptoKit Module

Cryptographic primitives powered by Phobos `std.digest`.

## Features

- **SHA-256** - Secure hash function
- **HMAC-SHA256** - Message authentication codes
- **Phobos-based** - Battle-tested cryptography

## Quick Start

### Build

```bash
# From kit/C directory
dub build --build=release --compiler=ldc2
```

### Test

```bash
# From kit/C directory
dub build --build=release --compiler=ldc2
cd source/cryptokit/build/test
./test
```

Expected output:
```
✅ SHA-256 and HMAC computed correctly
```

## Usage in C

```c
#include <cryptokit.h>
#include <stdio.h>
#include <string.h>

int main() {
    const char* msg = "Hello, Kit!";
    
    // SHA-256
    SHA256Hash hash = kit_sha256(msg, strlen(msg));
    printf("Hash: %02x%02x...\n", hash.hash[0], hash.hash[1]);
    
    // HMAC-SHA256
    const char* key = "secret";
    HMACResult hmac = kit_hmac_sha256(msg, strlen(msg), key, strlen(key));
    
    return 0;
}
```

## Handy Scripts

### Build & Test
```bash
#!/bin/bash
# From kit/C directory
dub build --build=release --compiler=ldc2
cd source/cryptokit/build/test
./test
echo "✅ Build and test complete!"
```

### Quick Compile User Code
```bash
#!/bin/bash
# Compile user program against CryptoKit
gcc myapp.c \
  -I../../source/cryptokit/build/include \
  -L../../source/cryptokit/build/lib \
  -lcryptokit \
  -Wl,-rpath,../../source/cryptokit/build/lib \
  -o myapp
./myapp
```

### Copy to System (Optional)
```bash
#!/bin/bash
# Install CryptoKit to system
sudo cp build/lib/libcryptokit.so /usr/local/lib/
sudo cp build/include/cryptokit.h /usr/local/include/
sudo ldconfig
echo "✅ CryptoKit installed to /usr/local/"
```

## Functions

### `kit_sha256`
```c
SHA256Hash kit_sha256(const char* data, size_t length);
```
Compute SHA-256 hash of data.

### `kit_hmac_sha256`
```c
HMACResult kit_hmac_sha256(const char* data, size_t data_len, 
                           const char* key, size_t key_len);
```
Compute HMAC-SHA256 for authentication.

## Directory Structure

```
cryptokit/
├── README.md                (this file)
├── cryptokit.d              (D source)
└── build/
    ├── include/cryptokit.h
    ├── lib/libcryptokit.so
    └── test/test            (runnable test)
```

## Next Steps

- Add more crypto functions (SHA-512, Blake2, etc.)
- Add password hashing (bcrypt, Argon2)
- Integrate with other Kit modules

---

**Powered by Phobos & D Language**
