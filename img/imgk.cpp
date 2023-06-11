#define KXVER 3
#include "k.h"
#include <cstring>
#include <stdint.h>
#include <vector>
//#include <iostream>

typedef uint16_t UH;
typedef uint32_t UI;
typedef uint64_t UJ;

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

unsigned char bmpHeader[] = {
    'B','M',
    0xff,0xff,0xff,0xff, //size: offset 2
    0x00,0x00,
    0x00,0x00,
    0x7a,0x00,0x00,0x00,
    0x6c,0x00,0x00,0x00,
    0xff,0xff,0xff,0xff, //width: offset 18
    0xff,0xff,0xff,0xff, //height: offset 22
    0x01,0x00,
    0x20,0x00,
    0x03,0x00,0x00,0x00,
    0xff,0xff,0xff,0xff, //raw size (incl.padding): offset 34
    0x13,0x0b,0x00,0x00,
    0x13,0x0b,0x00,0x00,
    0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,
    0x00,0x00,0xff,0x00,
    0x00,0xff,0x00,0x00,
    0xff,0x00,0x00,0x00,
    0x00,0x00,0x00,0xff,
    0x20,0x6e,0x69,0x57,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00
};

K k_imgToBmp(K src) {
    if (src->t != 0) return kerror("imgToBmp: src must be general list");
    int height = src->n;
    for (int i=0; i<height; ++i) {
        if(kK(src)[i]->t != 6) kerror("imgToBmp: all lines must be int lists");
    }
    int width = kK(src)[0]->n;
    int rawSize = width*height*4;
    int totalSize = 122+rawSize;
    K result = ktn(4, totalSize);
    unsigned char *p = kG(result);
    memcpy(p, bmpHeader, sizeof(bmpHeader));
    *(int*)(p+2) = totalSize;
    *(int*)(p+18) = width;
    *(int*)(p+22) = height;
    *(int*)(p+34) = rawSize;
    p += 122;
    for (int i=0; i<height; ++i) {
        int copyLen = width*sizeof(I);
        memcpy(p, kI(kK(src)[height-1-i]), copyLen);
        p += copyLen;
    }
    return result;
}

K k_bmpToImg(K src) {
    if (src->t != 4) return kerror("k_ddsToImg: src must be byte list");
    G *p = kG(src);
    int width = *(int*)(p+18);
    int height = *(int*)(p+22);
    int bpp = *(uint16_t*)(p+28);
    if (!(bpp == 32 || bpp == 24)) return kerror("k_ddsToImg: unknown format");
    K result = ktn(0, height);
    for (int i=0; i<height; ++i) kK(result)[i] = ktn(6, width);
    p += *(int*)(p+10);
    for (int i=0; i<height; ++i) {
        if (bpp == 32) {
            memcpy(kI(kK(result)[height-1-i]), p, width*4);
            p += width*4;
        } else {    //bpp=24
            K row = kK(result)[height-1-i];
            int *q = kI(row);
            for (int j=0; j<width; ++j) {
                *q = *(int*)p & 0x00ffffff;
                q += 1;
                p += 3;
            }
            p += (-(3*width))%4;
        }
    }
    return result;
}

K krect(size_t width, size_t height) {
    K result = ktn(0, height);
    for (int i=0; i<height; ++i) kK(result)[i] = ktn(6, width);
    return result;
}

K k_ddsToImg(K src) {
    if (src->t != 4) return kerror("k_ddsToImg: src must be byte list");
    G *p = kG(src);
    int width = *(int*)(p+16);
    int height = *(int*)(p+12);
    int flags = *(int*)(p+80);
    int format = 0;
    bool useAlpha = false;
    if (flags == 0x40) { format = 1; useAlpha = false; }    //RGB
    else if (flags == 0x41) { format = 1; useAlpha = true; }    //RGBA
    else if (flags == 4) {
        int fourcc = *(int*)(p+84);
        if (fourcc == 0x35545844) format = 2;   //DXT5
        if (fourcc == 0x33545844) format = 3;   //DXT3
        if (fourcc == 0x31545844) format = 4;   //DXT1
    }
    if (format == 0) return kerror("ddsToImg: unknown format");
    K result = ktn(0, height);
    for (int i=0; i<height; ++i) kK(result)[i] = ktn(6, width);
    p += 128;
    if (format == 1 && useAlpha) { //RGBA
        for (int i=0; i<height; ++i) {
            memcpy(kI(kK(result)[i]), p, width*4);
            p += width*4;
        }
    } else if (format == 1 && !useAlpha) { //RGB
        for (int i=0; i<height; ++i) {
            memcpy(kI(kK(result)[i]), p, width*4);
            for (int j=0; j<width; ++j) {
                kI(kK(result)[i])[j] = kI(kK(result)[i])[j] | 0xff000000;   //fix alpha channel
            }
            p += width*4;
        }
    } else if (format == 2) {
        int blocksH = (3+width)/4;
        int blocksV = (3+height)/4;
        for (int brow=0; brow<blocksV; ++brow)
            for (int bcol=0; bcol<blocksH; ++bcol) {
                uint16_t c0 = *(uint16_t*)(p+8);
                uint16_t c1 = *(uint16_t*)(p+10);
                unsigned char r[4];
                unsigned char g[4];
                unsigned char b[4];
                uint32_t rgb[4];
                r[0] = ((c0>>11)&0b11111)<<3;
                g[0] = ((c0>>5)&0b111111)<<2;
                b[0] = (c0 & 0b11111)<<3;
                r[1] = ((c1>>11)&0b11111)<<3;
                g[1] = ((c1>>5)&0b111111)<<2;
                b[1] = (c1 & 0b11111)<<3;
                if (c0>c1) {
                    r[2] = (2*r[0]+1*r[1])/3;
                    g[2] = (2*g[0]+1*g[1])/3;
                    b[2] = (2*b[0]+1*b[1])/3;
                    r[3] = (1*r[0]+2*r[1])/3;
                    g[3] = (1*g[0]+2*g[1])/3;
                    b[3] = (1*b[0]+2*b[1])/3;
                } else {
                    r[2] = (r[0]+r[1])/2;
                    g[2] = (g[0]+g[1])/2;
                    b[2] = (b[0]+b[1])/2;
                    r[3] = 0;
                    g[3] = 0;
                    b[3] = 0;
                }
                for (int col=0; col<4; ++col) {
                    rgb[col] = b[col]+(g[col]<<8)+(r[col]<<16);
                }
                uint32_t colors = *(uint32_t*)(p+12);
                for (int px=0; px<16; ++px) {
                    I pxc = rgb[colors & 0b11];
                    colors >>= 2;
                    kI(kK(result)[4*brow+px/4])[4*bcol+px%4] = pxc;
                }

                unsigned char a[8];
                a[0] = *p;
                a[1] = *(p+1);
                if(a[0]>a[1]) {
                    a[2] = (6*a[0]+1*a[1])/7;
                    a[3] = (5*a[0]+2*a[1])/7;
                    a[4] = (4*a[0]+3*a[1])/7;
                    a[5] = (3*a[0]+4*a[1])/7;
                    a[6] = (2*a[0]+5*a[1])/7;
                    a[7] = (1*a[0]+6*a[1])/7;
                } else {
                    a[2] = (4*a[0]+1*a[1])/5;
                    a[3] = (3*a[0]+2*a[1])/5;
                    a[4] = (2*a[0]+3*a[1])/5;
                    a[5] = (1*a[0]+4*a[1])/5;
                    a[6] = 0;
                    a[7] = 255;
                }
                J alphas = J(*(uint32_t*)(p+2))+(J(*(uint16_t*)(p+6))<<32);
                for (int px=0; px<16; ++px) {
                    I pxa = a[alphas & 7];
                    alphas >>= 3;
                    kI(kK(result)[4*brow+px/4])[4*bcol+px%4] |= (pxa << 24);
                }
                p += 16;
            }
    } else if (format == 3) {
        int blocksH = (3+width)/4;
        int blocksV = (3+height)/4;
        for (int brow=0; brow<blocksV; ++brow)
            for (int bcol=0; bcol<blocksH; ++bcol) {
                uint16_t c0 = *(uint16_t*)(p+8);
                uint16_t c1 = *(uint16_t*)(p+10);
                unsigned char r[4];
                unsigned char g[4];
                unsigned char b[4];
                uint32_t rgb[4];
                r[0] = ((c0>>11)&0b11111)<<3;
                g[0] = ((c0>>5)&0b111111)<<2;
                b[0] = (c0 & 0b11111)<<3;
                r[1] = ((c1>>11)&0b11111)<<3;
                g[1] = ((c1>>5)&0b111111)<<2;
                b[1] = (c1 & 0b11111)<<3;
                r[2] = (2*r[0]+1*r[1])/3;
                g[2] = (2*g[0]+1*g[1])/3;
                b[2] = (2*b[0]+1*b[1])/3;
                r[3] = (1*r[0]+2*r[1])/3;
                g[3] = (1*g[0]+2*g[1])/3;
                b[3] = (1*b[0]+2*b[1])/3;
                for (int col=0; col<4; ++col) {
                    rgb[col] = b[col]+(g[col]<<8)+(r[col]<<16);
                }
                uint32_t colors = *(uint32_t*)(p+12);
                for (int px=0; px<16; ++px) {
                    I pxc = rgb[colors & 0b11];
                    colors >>= 2;
                    kI(kK(result)[4*brow+px/4])[4*bcol+px%4] = pxc;
                }

                for (int i=0; i<8; ++i) {
                    I a0 = (((*(p+i)) & 0x0f) << 4)*255/240;
                    I a1 = (((*(p+i)) & 0xf0))*255/240;
                    I px0 = i*2;
                    I px1 = px0+1;
                    kI(kK(result)[4*brow+px0/4])[4*bcol+px0%4] |= (a0 << 24);
                    kI(kK(result)[4*brow+px1/4])[4*bcol+px1%4] |= (a1 << 24);
                }
                p += 16;
            }
    } else if (format == 4) {
        int blocksH = (3+width)/4;
        int blocksV = (3+height)/4;
        for (int brow=0; brow<blocksV; ++brow)
            for (int bcol=0; bcol<blocksH; ++bcol) {
                uint16_t c0 = *(uint16_t*)(p+0);
                uint16_t c1 = *(uint16_t*)(p+2);
                unsigned char r[4];
                unsigned char g[4];
                unsigned char b[4];
                uint32_t rgb[4];
                r[0] = ((c0>>11)&0b11111)<<3;
                g[0] = ((c0>>5)&0b111111)<<2;
                b[0] = (c0 & 0b11111)<<3;
                r[1] = ((c1>>11)&0b11111)<<3;
                g[1] = ((c1>>5)&0b111111)<<2;
                b[1] = (c1 & 0b11111)<<3;
                if (c0>c1) {
                    r[2] = (2*r[0]+1*r[1])/3;
                    g[2] = (2*g[0]+1*g[1])/3;
                    b[2] = (2*b[0]+1*b[1])/3;
                    r[3] = (1*r[0]+2*r[1])/3;
                    g[3] = (1*g[0]+2*g[1])/3;
                    b[3] = (1*b[0]+2*b[1])/3;
                } else {
                    r[2] = (r[0]+r[1])/2;
                    g[2] = (g[0]+g[1])/2;
                    b[2] = (b[0]+b[1])/2;
                    r[3] = 0;
                    g[3] = 0;
                    b[3] = 0;
                }
                for (int col=0; col<4; ++col) {
                    rgb[col] = b[col]+(g[col]<<8)+(r[col]<<16);
                }
                uint32_t colors = *(uint32_t*)(p+4);
                for (int px=0; px<16; ++px) {
                    I pxc = rgb[colors & 0b11];
                    colors >>= 2;
                    kI(kK(result)[4*brow+px/4])[4*bcol+px%4] = pxc + (0xff << 24);
                }
                p += 8;
            }
    }
    return result;
}

K k_tgaToImg(K src) {
    if (src->t != 4) return kerror("tgaToImg: src must be byte list");
    G *p = kG(src);
    G idLength = *p++;
    if (idLength != 0) return kerror("tgaToImg: image with ID not supported");
    G colorMapType = *p++;
    if (colorMapType != 0) return kerror("tgaToImg: unsupported colorMapType");
    G imageType = *p++;
    if(imageType != 2) return kerror("tgaToImg: unsupported imageType");
    p += 5; //colorMapSpec
    p += 4; //xOrigin, yOrigin
    UH width = *(UH*)p; p+=2;
    UH height = *(UH*)p; p+=2;
    G pixelDepth = *p++;
    if (pixelDepth != 32) return kerror("tgaToImg: unsupported pixelDepth");
    G imgDescr = *p++;
    if (imgDescr != 8) return kerror("tgaToImg: unsupported imgDescr");
    K result = krect(width,height);
    for (int i=0; i<height; ++i) {
        memcpy(kI(kK(result)[height-1-i]), p, width*4);
        p += width*4;
    }
    return result;
}

}
