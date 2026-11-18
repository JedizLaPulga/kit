module cryptokit.cryptokit;

import std.digest.sha : SHA256_digest = SHA256;
import core.stdcpp.string : basic_string;

extern(C++, "kit"):

alias cpp_string = basic_string!char;

// SHA-256 Hash Result
extern(C++) struct Hash {
    ubyte[32] digest;
}

// SHA-256 Hasher
extern(C++) class Hasher {
private:
    SHA256_digest _hasher;
    
public:
    extern(C++) this() {
        _hasher.start();
    }
    
    extern(C++) void update(ref const(cpp_string) msg) {
        const char* ptr = msg.c_str();
        size_t len = msg.size();
        _hasher.put(cast(const ubyte[])ptr[0 .. len]);
    }
    
    extern(C++) Hash finish() {
        ubyte[32] digest = _hasher.finish();
        Hash result;
        result.digest[] = digest[];
        return result;
    }
}

// Static interface
extern(C++) static Hash computeSHA256(ref const(cpp_string) msg) {
    SHA256_digest hasher;
    hasher.start();
    const char* ptr = msg.c_str();
    size_t len = msg.size();
    hasher.put(cast(const ubyte[])ptr[0 .. len]);
    ubyte[32] digest = hasher.finish();
    
    Hash result;
    result.digest[] = digest[];
    return result;
}

extern(C++) static Hasher createHasher() {
    return new Hasher();
}
