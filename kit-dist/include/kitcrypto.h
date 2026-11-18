#ifndef KITCRYPTO_H
#define KITCRYPTO_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    unsigned char hash[32];
} SHA256Hash;

typedef struct {
    unsigned char digest[32];
} HMACResult;

SHA256Hash kit_sha256(const char* data, size_t length);
HMACResult kit_hmac_sha256(const char* data, size_t data_len, 
                           const char* key, size_t key_len);

#ifdef __cplusplus
}
#endif

#endif
