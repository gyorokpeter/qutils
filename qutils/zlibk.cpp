#define KXVER 3
#include "k.h"
#include <cstring>
#include <stdint.h>
#include <zlib.h>
#include <vector>

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

K k_zlib_compress(K src) {
    if (src->t != 4) return kerror("compress: expecting byte vector");
    uLong sourceLen = src->n;
    std::vector<uint8_t> dest(compressBound(sourceLen));
    uLongf destLen = dest.size();
    compress(&dest[0],&destLen,kG(src),sourceLen);
    K result = ktn(4, destLen);
    memcpy(kG(result),&dest[0],destLen);
    return result;
}

K k_zlib_uncompress(K src) {
    if (src->t != 4) return kerror("uncompress: expecting byte vector");
    std::vector<uint8_t> dest(1000000);
    uLongf destLen = dest.size();
    uncompress(&dest[0],&destLen,kG(src),src->n);
    K result = ktn(4, destLen);
    memcpy(kG(result),&dest[0],destLen);
    return result;
}

}
