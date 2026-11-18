# Changelog

All notable changes to Kit are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/).

---

## [0.1.0-alpha] - 2026

### Foundation Release: Kit-C with KitCrypto Module

Established the foundational architecture for Kit: a modular, Phobos-powered cryptographic library framework for C/C++ FFI bindings using D and LDC2.

#### Added

**Core Architecture** (Design & Infrastructure)
- Modular project structure with self-contained build directories
- Hybrid architecture: per-module builds + central collection
- Automated `INSTALL.sh` collection script with 4 installation options
- Support for multiple independent modules (design complete, KitCrypto implemented)

**KitCrypto Module** (Cryptographic Functions)
- **SHA-256 Hashing** via Phobos `std.digest.sha`
  - Function: `kit_sha256(const ubyte* data, size_t length) → SHA256Hash`
  - Secure hash computation for data integrity
  - Phobos-based implementation with zero external dependencies
  
- **HMAC-SHA256** via Phobos `std.digest.hmac`
  - Function: `kit_hmac_sha256(const ubyte* data, size_t data_len, const ubyte* key, size_t key_len) → HMACResult`
  - Message authentication for API signature verification
  - Timing-attack resistant constant-time comparison
  - Phobos foundation with security-first design

- C FFI Bindings (extern(C))
  - Portable `kitcrypto.h` header with clean C API
  - Type mappings: D `ubyte` ↔ C `unsigned char` (automatic via LDC2)
  - Struct definitions: `SHA256Hash` (32-byte hash), `HMACResult` (32-byte MAC)
  - Compiled shared library: `libkitcrypto.so`

**Testing & Quality**
- Self-contained test suite: `source/kitCrypto/build/test/test.c` (27 lines)
- Verified SHA-256 output: `b67d1b3ab0d839eb8bc1156b8717bb441c897fcab323374e2ae530a40632feba`
- Verified HMAC output: `1c061a9f9652e803b8ca3fc972e023f8d43136380e7542d829e7980deacd6b94`
- Tests use relative paths for portability
- Runtime linking verified with `-Wl,-rpath` flag

**Documentation**
- **Root README** (`README.md`) - Project vision and marketing
- **Installation Guide** (`INSTALL_GUIDE.md`) - 4 installation methods, CI/CD integration
- **Architecture Guide** (`DISTRIBUTION_WORKFLOW.md`) - Detailed workflow and design decisions
- **Module README** (`C/README.md`) - C-specific features and quickstart
- **KitCrypto README** (`C/source/kitCrypto/README.md`) - Module documentation with example scripts
- **Build Helpers** - 3 scripts for quick build/compile/install tasks
- **This CHANGELOG** - Version history and tracking

**Build System**
- LDC2 compiler integration with Dub package manager
- Release build optimizations (`-O3` via LDC2)
- Clean separation: source → build → distribution
- Support for future C++ bindings (architecture prepared)

#### Technical Details

**Naming Convention**
- Header file name matches library name: `kitcrypto.h` ↔ `libkitcrypto.so`
- Professional FFI design for consistency and discoverability

**Directory Structure**
```
kit/C/
├── source/kitCrypto/
│   ├── kitcrypto.d                  ← D source (45 lines)
│   ├── README.md                    ← Module docs
│   └── build/                       ← Self-contained builds
│       ├── include/kitcrypto.h
│       ├── lib/libkitcrypto.so
│       └── test/test.c + test
│
├── build/                           ← Central collection
│   ├── include/kitcrypto.h
│   └── lib/libkitcrypto.so
│
├── INSTALL.sh                       ← Automation
├── dub.json                         ← Build config
└── README.md                        ← This file
```

**Phobos Integration**
- `std.digest.sha` for SHA-256 implementation
- `std.digest.hmac` for HMAC wrapper
- Zero additional dependencies (pure Phobos)
- Seamlessly exposed via extern(C) function ABI

#### Performance
- Compiled with LDC2 optimization flags
- Native x86-64 code generation
- No JIT or interpreter overhead
- Phobos algorithms battle-tested and production-ready

#### Status
- ✅ Build verified
- ✅ Cryptographic functions implemented and tested
- ✅ C FFI bindings working correctly
- ✅ Documentation complete
- ✅ Ready for additional modules

#### Known Limitations
- Linux target only (can be extended to Windows/macOS)
- Currently supports only C bindings (C++ bindings in extern(C++) format ready for implementation)
- Module count: 1 (architecture supports unlimited)

#### Next Phase (Planned)
- Additional crypto functions: SHA-512, Blake2, Argon2
- C++ module with extern(C++) bindings
- Async/parallel task module
- JSON parsing module
- Networking utilities module

---

## Development Timeline

### Session: Foundation & KitCrypto Setup

**Phase 1: Architecture Design**
- Defined dual-build strategy (modular + centralized)
- Created INSTALL.sh automation
- Designed naming conventions and directory structure

**Phase 2: KitCrypto Implementation**
- Wrote `kitcrypto.d` with Phobos crypto functions (45 lines)
- Generated C header with extern(C) declarations
- Compiled to `libkitcrypto.so` with LDC2

**Phase 3: Testing & Verification**
- Created `test.c` test suite (27 lines)
- Verified SHA-256 and HMAC-SHA256 outputs
- Confirmed runtime linking with `-Wl,-rpath`

**Phase 4: Documentation**
- Root README with project vision
- Installation guide with 4 methods
- Module-level documentation
- Architecture workflow guide
- Helper scripts for common tasks

**Phase 5: Cleanup & Optimization**
- Removed unnecessary artifacts (`.di` files, duplicate `.o` files)
- Enforced strict build directory discipline
- Verified portable test with relative paths
- Confirmed module independence

---

## Version Tracking

| Version | Status | Date | Features |
|---------|--------|------|----------|
| 0.1.0-alpha | Active | 2024 | KitCrypto with SHA-256, HMAC-SHA256 |
| 0.2.0 (Planned) | - | - | Additional crypto functions |
| 0.3.0 (Planned) | - | - | C++ bindings |
| 1.0.0 (Planned) | - | - | Full feature set, stability |

---

## Notes

- **Build System:** Dub + LDC2 (no external build complexity)
- **Dependencies:** None (pure Phobos)
- **Code Quality:** Clean, documented, tested
- **Target Audience:** C/C++ developers needing crypto without external libraries
- **Philosophy:** Phobos power, exposed through native C/C++ ABIs

---

**Last Updated:** 2024
**Maintained By:** Kit Development Team
**Repository:** [Kit](https://github.com/your-org/Kit)
