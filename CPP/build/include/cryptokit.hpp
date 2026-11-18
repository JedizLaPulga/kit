// LDC2-generated C++ header with std::string support wrapper

#pragma once

#include <assert.h>
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <string>

template <typename T, typename Traits, typename Alloc>
class basic_string;
template <typename CharT>
struct char_traits;
template <typename T>
class allocator;

namespace kit
{
    struct Hash final
    {
        uint8_t digest[32LLU];
        Hash()
        {
        }
    };

    class Hasher
    {
    private:
        void* _hasher;
    public:
        Hasher();
        ~Hasher();
        virtual void update(const std::string& msg);
        virtual Hash finish();
    };

    extern Hash computeSHA256(const std::string& msg);

    extern Hasher* createHasher();

}
