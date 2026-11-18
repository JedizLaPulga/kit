module cryptokit.cryptokit;

import std.digest.sha;
import std.digest.hmac;
import std.array : array;
import core.stdc.string : memcpy;

extern(C):

// Simple SHA-256 hash result (32 bytes)
struct SHA256Hash {
    ubyte[32] hash;
}

// HMAC-SHA256 result
struct HMACResult {
    ubyte[32] digest;
}

/// Compute SHA-256 hash of data
SHA256Hash kit_sha256(const char* data, size_t length) {
    SHA256 hasher;
    hasher.start();
    hasher.put(cast(const ubyte[])data[0 .. length]);
    
    ubyte[32] digest = hasher.finish();
    
    SHA256Hash result;
    memcpy(result.hash.ptr, digest.ptr, 32);
    return result;
}

/// Compute HMAC-SHA256
HMACResult kit_hmac_sha256(const char* data, size_t data_len, 
                           const char* key, size_t key_len) {
    auto hmacResult = hmac!SHA256(
        cast(const ubyte[])key[0 .. key_len],
        cast(const ubyte[])data[0 .. data_len]
    );
    
    HMACResult result;
    memcpy(result.digest.ptr, hmacResult.ptr, 32);
    return result;
}
