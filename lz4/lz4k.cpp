#define KXVER 3
#include "k.h"
#include <cstring>
#include <stdint.h>
#include <lz4.h>
#include <vector>

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

K k_lz4_compress(K src) {
    if (src->t != 4) return kerror("compress: expecting byte vector");
    int srcSize = src->n;
    std::vector<uint8_t> dst(LZ4_compressBound(srcSize));
    int dstCapacity = dst.size();
    int outBytes = LZ4_compress_default((const char*)kG(src), (char*)&dst[0], srcSize, dstCapacity);
    K result = ktn(4, outBytes);
    memcpy(kG(result),&dst[0],outBytes);
    return result;
}

K k_lz4_uncompress(K src, K outBytes) {
    if (src->t != 4) return kerror("uncompress: expecting byte vector");
    if (outBytes->t != -6) return kerror("uncompress: outBytes must be int");
    int dstCapacity = outBytes->i;
    K result = ktn(4, dstCapacity);
    int res = LZ4_decompress_safe((const char*)kG(src), (char*)kG(result), src->n, dstCapacity);
    return result;
}

}
