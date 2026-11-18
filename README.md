# 🛠️ Kit - Modern Modular Library for C/C++ 

A powerful D language library project that generates high-performance FFI bindings for **C** and **C++** using the **Phobos** standard library as a foundation. Kit compiles D code with **LDC2** to produce native libraries with clean C and C++ APIs.

---

## 🎯 Project Overview

**Kit** bridges the gap between D's expressiveness and C/C++'s universality. We build robust, type-safe libraries in D and seamlessly expose them to C and C++ through:

- **C Interop**: Clean `extern(C)` FFI bindings with struct-based APIs
- **C++ Interop**: Object-oriented `extern(C++)` bindings with method calls and classes
- **Cross-Platform Support**: Linux-focused development with Phobos runtime
- **Zero-Cost Abstractions**: Native performance through direct LDC2 compilation

---

## 📁 Project Structure

```
Kit/
├── C/              # C language bindings
│   ├── source/     # D source files exporting C API
│   ├── dub.json    # Dub configuration for C library
│   └── README.md
├── CPP/            # C++ language bindings
│   ├── source/     # D source files exporting C++ API
│   ├── dub.json    # Dub configuration for C++ library
│   └── README.md
└── README.md       # This file
```

Each directory contains a complete D language project using **Dub** as the build system.

---

## ⚡ Quick Start - Use Kit in 60 Seconds

```bash
# 1. Build & Install
git clone https://github.com/your-org/kit.git && cd kit/C
dub build --build=release && sudo cp lib/* /usr/local/lib/ && sudo cp -r include/* /usr/local/include/

# 2. Use in your C code
#include <kit/crypto.h>
kit_hmac_sha256(message, msg_len, key, key_len);

# 3. Compile
gcc main.c -lkit -o app && ./app
```

✅ Done! No dependency hell, no complex build setup.

---

## 🚀 Getting Started

### Prerequisites

- **LDC2** (LLVM D Compiler) - [Install LDC2](https://github.com/ldc-developers/ldc)
- **Dub** - D package manager (usually bundled with LDC2)
- **Linux** (primary target environment)
- Standard C/C++ development tools (gcc/g++, make, etc.)

### Building the Libraries

#### Build C Library

```bash
cd kit/C
dub build --build=release
# Output: Generated headers in include/, libraries in lib/
```

#### Build C++ Library

```bash
cd kit/CPP
dub build --build=release
# Output: Generated headers in include/, libraries in lib/
```

### Generate Header Files

```bash
# Generate C headers (.h)
ldc2 -H -Hd=include source/app.d

# Generate C++ headers (.hpp)
ldc2 -H -Hd=include source/app.d -extern-std=c++
```

---

## 🎁 What Kit Provides

One `.so` library that eliminates the need for multiple dependencies:

**Concurrency & Async**
- Work-stealing task scheduler that automatically uses all CPU cores
- Type-safe channels for thread communication (zero data races)
- Lightweight task spawning for handling thousands of concurrent operations

**Data & Networking**
- Production-grade JSON parser with streaming support
- Full HTTP client/server with connection pooling and automatic retries
- WebSocket support with automatic frame handling

**Security & Cryptography**
- SHA-256, HMAC with timing-attack resistant operations
- Cryptographically secure random number generation
- Password hashing and verification functions

**Data Processing**
- Lazy evaluation chains (filter → map → reduce) with zero overhead
- Sophisticated regex engine with captured groups
- Streaming JSON parser for processing large datasets

**Everything else**
- File I/O utilities, path handling, compression
- Date/time parsing with timezone support
- Statistical functions and algorithms

*All powered by Phobos—D's production-grade standard library.*

---

## 📚 Real-World Examples

Just include the generated headers, link against Kit's `.so`, and you're done. No dependencies, no complex setup—just modern, efficient native libraries.

---

### Example 1: Lazy Range Processing (C)

**Header File:** `#include <kit/pipeline.h>`

```c
#include <kit/pipeline.h>
#include <stdio.h>

int is_even(int x) { return x % 2 == 0; }
int square(int x) { return x * x; }

int main() {
    int data[1000000];
    for (int i = 0; i < 1000000; i++) data[i] = i;
    
    // Build a lazy pipeline: filter(even) -> map(square) -> sum
    Pipeline* p = kit_pipeline_new(data, 1000000);
    p = kit_pipeline_filter(p, is_even);
    p = kit_pipeline_map(p, square);
    
    // Single-pass computation, no intermediate allocations
    int total = kit_pipeline_sum(p);
    printf("Sum of squares of even numbers: %d\n", total);
    
    kit_pipeline_free(p);
    return 0;
}
```

**Compile & Link:**
```bash
gcc -c main.c -I./include
gcc main.o -o app -L./lib -lkit
./app
```

✨ *Kit's pipeline leverages efficient range composition—process millions of records in a single pass.*

---

### Example 2: Streaming JSON Parser (C)

**Header File:** `#include <kit/json_stream.h>`

```c
#include <kit/json_stream.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    int count;
    double total_price;
} Stats;

void on_product(JsonValue* obj, void* context) {
    Stats* stats = (Stats*)context;
    
    const char* name = kit_json_get_string(obj, "name");
    double price = kit_json_get_number(obj, "price");
    
    stats->count++;
    stats->total_price += price;
    printf("Found: %s ($%.2f)\n", name, price);
}

int main() {
    JsonParser* parser = kit_json_parser_new(4096);
    Stats stats = {0, 0.0};
    
    // Parse streaming data from file or network
    const char* chunk = "{\"name\":\"Laptop\",\"price\":999.99}\n"
                        "{\"name\":\"Mouse\",\"price\":29.99}\n";
    
    kit_json_parse_chunk(parser, chunk, strlen(chunk), on_product, &stats);
    
    printf("\nTotal: %d items, Avg: $%.2f\n", 
           stats.count, stats.total_price / stats.count);
    
    kit_json_parser_free(parser);
    return 0;
}
```

**Compile & Link:**
```bash
gcc -c main.c -I./include
gcc main.o -o app -L./lib -lkit
./app
```

✨ *Robust JSON streaming without dependencies—handles malformed data gracefully.*

---

### Example 3: Cryptographic Hashing (C)

**Header File:** `#include <kit/crypto.h>`

```c
#include <kit/crypto.h>
#include <stdio.h>
#include <string.h>

int main() {
    // Generate HMAC-SHA256 for API authentication
    const char* key = "your-secret-key";
    const char* message = "user_id=42&action=purchase";
    
    HMACResult hmac = kit_hmac_sha256(message, strlen(message),
                                     key, strlen(key));
    
    printf("HMAC: ");
    for (int i = 0; i < 32; i++) printf("%02x", hmac.digest[i]);
    printf("\n");
    
    // Hash large files efficiently
    StreamHash* hasher = kit_stream_hash_new();
    
    FILE* f = fopen("large_file.bin", "rb");
    char buffer[65536];
    size_t read;
    while ((read = fread(buffer, 1, sizeof(buffer), f)) > 0) {
        kit_stream_hash_update(hasher, buffer, read);
    }
    fclose(f);
    
    SHA256Hash file_hash = kit_stream_hash_finish(hasher);
    
    printf("File SHA256: ");
    for (int i = 0; i < 32; i++) printf("%02x", file_hash.hash[i]);
    printf("\n");
    
    kit_stream_hash_free(hasher);
    return 0;
}
```

**Compile & Link:**
```bash
gcc -c main.c -I./include
gcc main.o -o app -L./lib -lkit
./app
```

✨ *Cryptographic primitives built-in—no external dependencies, constant-time operations prevent timing attacks.*

---

### Example 4: Async Task Scheduling (C++)

**Header File:** `#include <kit/async.hpp>`

```cpp
#include <kit/async.hpp>
#include <iostream>

int main() {
    // Create worker pool for parallel computation
    kit::WorkerPool pool(4);  // 4 threads
    
    int results[1000];
    
    // Submit 1000 tasks
    for (int i = 0; i < 1000; ++i) {
        int task_id = i;
        pool.submit([task_id, &results]() {
            int sum = 0;
            for (int j = 0; j < 100000; ++j) {
                sum += (task_id * j) % 1000;
            }
            results[task_id] = sum;
        });
    }
    
    // Wait for all to complete
    pool.wait_all();
    
    std::cout << "Computed " << 1000 << " results" << std::endl;
    return 0;
}
```

**Compile & Link:**
```bash
g++ -std=c++17 -c main.cpp -I./include
g++ main.o -o app -L./lib -lkit
./app
```

✨ *Work-stealing scheduler automatically load-balances across all cores.*

---

### Example 5: Producer-Consumer with Channels (C++)

**Header File:** `#include <kit/async.hpp>`

```cpp
#include <kit/async.hpp>
#include <iostream>
#include <thread>

int main() {
    // Type-safe channels for thread communication
    kit::Channel<std::string> messages(10);
    
    // Producer thread
    kit::AsyncTask producer = kit::AsyncTask::spawn([&messages]() {
        for (int i = 0; i < 5; ++i) {
            messages.send("Message " + std::to_string(i));
            std::this_thread::sleep_for(
                std::chrono::milliseconds(100)
            );
        }
        messages.close();
    });
    
    // Consumer thread
    kit::AsyncTask consumer = kit::AsyncTask::spawn([&messages]() {
        std::string msg;
        while (messages.try_receive(msg, 1000)) {
            std::cout << "Received: " << msg << std::endl;
        }
    });
    
    producer.await();
    consumer.await();
    
    std::cout << "Done!" << std::endl;
    return 0;
}
```

**Compile & Link:**
```bash
g++ -std=c++17 -c main.cpp -I./include
g++ main.o -o app -L./lib -lkit
./app
```

✨ *Message-passing concurrency—no data races, no mutexes.*

---

### Example 6: HTTP REST Client (C)

**Header File:** `#include <kit/http.h>`

```c
#include <kit/http.h>
#include <stdio.h>

int main() {
    HttpClient* client = kit_http_client_new();
    
    // Simple GET request with 5-second timeout
    HttpResponse* resp = kit_http_get(
        client,
        "https://api.github.com/users/torvalds",
        5000
    );
    
    if (resp->status_code == 200) {
        printf("Status: %d\n", resp->status_code);
        printf("Content-Type: %s\n",
               kit_http_get_header(resp, "content-type"));
        printf("Response:\n%.*s\n",
               (int)resp->body_len, resp->body);
    } else {
        printf("Error: HTTP %d\n", resp->status_code);
    }
    
    kit_http_response_free(resp);
    kit_http_client_free(client);
    return 0;
}
```

**Compile & Link:**
```bash
gcc -c main.c -I./include
gcc main.o -o app -L./lib -lkit
./app
```

✨ *Built-in HTTP client with connection pooling—non-blocking I/O, no callback hell.*

---

### Example 7: Pattern Matching & Log Analysis (C)

**Header File:** `#include <kit/regex.h>`

```c
#include <kit/regex.h>
#include <stdio.h>

int main() {
    // Compile pattern: extract IP, timestamp, method, path, status
    Regex* pattern = kit_regex_compile(
        r"(\d+\.\d+\.\d+\.\d+) - - \[(.+?)\] "
        r"\"(\w+) (.+?) HTTP/[\d.]+\" (\d+)"
    );
    
    const char* log = "192.168.1.100 - - [18/Nov/2026:09:12:34 +0100] "
                      "\"GET /api/users HTTP/1.1\" 200";
    
    RegexMatch* match = kit_regex_find(pattern, log);
    if (match && match->num_captures >= 5) {
        printf("IP:     %s\n", match->captures[0]);
        printf("Time:   %s\n", match->captures[1]);
        printf("Method: %s\n", match->captures[2]);
        printf("Path:   %s\n", match->captures[3]);
        printf("Status: %s\n", match->captures[4]);
        
        kit_regex_match_free(match);
    }
    
    kit_regex_free(pattern);
    return 0;
}
```

**Compile & Link:**
```bash
gcc -c main.c -I./include
gcc main.o -o app -L./lib -lkit
./app
```

✨ *Sophisticated pattern matching with captured groups—process massive log files efficiently.*

---

## 🎓 Key Benefits

🚀 **Drop-In Native Performance** — Single `.so` file replaces multiple dependencies

🎯 **Zero Configuration** — Just include headers and link—no complex build setup

📦 **Production-Ready** — Battle-tested algorithms, optimized by LDC2 compiler

✨ **Modern APIs** — Clean C/C++ interfaces that feel natural to use

🔗 **No External Dependencies** — Crypto, JSON, networking, concurrency all built-in

🛡️ **Secure by Default** — Cryptographic operations use constant-time implementations

*Engineered with Phobos & D Language—sophisticated libraries made simple.*

---

## 🌟 Why Choose Kit?

### Modern FFI Without the Friction

| Feature | Manual C/C++ Build | Third-Party Libs | **Kit** |
|---------|------------------|------------------|--------|
| **Setup Time** | Days | Days | Minutes |
| **Dependencies** | External packages | External packages | None—single `.so` |
| **Performance** | Good | Good | **Optimized by LDC2** ⚡ |
| **API Quality** | Varies | Varies | **Consistent, modern** |
| **Maintenance** | Yours | Community | **Active development** |

✨ *Powered by Phobos & D*—All the sophisticated algorithms you need, compiled into a single, efficient native library.

---

## 🔧 Integration Guide

### Using Kit in Your C Project

```bash
# 1. Download Kit or build from source
git clone https://github.com/your-org/kit.git
cd kit/C && dub build --build=release

# 2. Copy headers and libraries
cp -r include/* /usr/local/include/
cp lib/* /usr/local/lib/

# 3. Link against Kit in your project
gcc main.c -I/usr/local/include -L/usr/local/lib -lkit -o app
./app
```

### Using Kit in Your C++ Project

```bash
# 1. Build Kit C++ bindings
cd kit/CPP && dub build --build=release

# 2. Install
cp -r include/* /usr/local/include/
cp lib/* /usr/local/lib/

# 3. Link in your project
g++ -std=c++17 main.cpp -I/usr/local/include -L/usr/local/lib -lkit -o app
./app
```

**That's it!** No complex dependency management, no build system integration—just link and go.

*Internally powered by Phobos & D*—while you enjoy clean C/C++ APIs, sophisticated algorithms run under the hood.

---

## 📖 Documentation

Each subdirectory contains detailed documentation:

- **[C Library Documentation](./C/README.md)** - C-specific binding patterns and examples
- **[C++ Library Documentation](./CPP/README.md)** - C++ interop best practices
- **[Module Creation Guide](./MODULE_CREATION_GUIDE.md)** - How to create new Kit modules (kitAsync, kitJSON, etc.)
- **[Installation & Distribution](./INSTALL_GUIDE.md)** - 4 installation methods and CI/CD integration
- **[Architecture Workflow](./DISTRIBUTION_WORKFLOW.md)** - Design decisions and module organization
- **[Changelog](./CHANGELOG.md)** - Version history and release notes

---

## 🤝 Contributing

We welcome contributions! Areas of interest:

- New Phobos-powered library implementations
- Performance optimizations and benchmarks
- Binding examples and tutorials
- Documentation improvements
- Bug reports and fixes

---

## 📄 License

Please see LICENSE file in the repository root for licensing information.

---

## 🔗 Useful Resources

- [LDC2 Documentation](https://wiki.dlang.org/LDC)
- [D Language Reference](https://dlang.org/spec/spec.html)
- [Phobos Standard Library](https://dlang.org/phobos/)
  - [std.range](https://dlang.org/phobos/std_range.html) - Lazy evaluation
  - [std.concurrency](https://dlang.org/phobos/std_concurrency.html) - Async & channels
  - [std.json](https://dlang.org/phobos/std_json.html) - JSON parsing
  - [std.digest](https://dlang.org/phobos/std_digest.html) - Cryptography
  - [std.regex](https://dlang.org/phobos/std_regex.html) - Pattern matching
  - [std.socket](https://dlang.org/phobos/std_socket.html) - Networking
- [Dub Package Manager](https://dub.pm/)
- [D FFI Guide](https://dlang.org/spec/interfaceToC.html)
- [C++ Interop in D](https://dlang.org/spec/cpp_interface.html)

---

**Built with ❤️ using the D Language | Powered by Phobos and LDC2**
