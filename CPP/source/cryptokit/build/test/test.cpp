#include "../include/cryptokit.hpp"
#include <iostream>
#include <cstdio>
#include <string>

using namespace kit;

int main() {
    // Test 1: computeSHA256 with std::string
    //std::string msg = "hello";
    Hash hash = computeSHA256("hello");
    printf("SHA256(hello) = ");
    for (int i = 0; i < 32; i++) {
        printf("::");
        printf("%02x", hash.digest[i]);
    }
    printf("\n");
    
    // Test 2: Streaming with std::string
    Hasher* hasher = createHasher();
    std::string msg2 = "hello";
    hasher->update(msg2);
    Hash result = hasher->finish();
    printf("Streaming = ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", result.digest[i]);
    }
    printf("\n");
    
    return 0;
}
