#define KXVER 3
#include "k.h"
#include <cstring>
#include <stdint.h>
#include <string>
#include <unordered_map>
#include <iostream>
#include <tuple>

#include "qutils.hpp"

std::unordered_map<std::string,std::string> replaceDict;

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

K initTZ(K unused) {
    initTZImpl();
    return K(0);
}

K wcharToUtf8(K str) {
    if (str->t != 10) return kerror("str must be string");
    char *utf8Text = UnicodeToCodePage(65001,(wchar_t*)kC(str), str->n/2);
    int len = strlen(utf8Text);
    K result = ktn(10,len);
    memcpy(kC(result),utf8Text,len);
    delete [] utf8Text;
    return result;
}

K utf8toCP(K str, K cp) {
    if (str->t != 10) return kerror("str must be string");
    if (cp->t != -7) return kerror("cp must be long");
    wchar_t *wText2 = CodePageToUnicode(65001,(char*)kC(str),str->n);
    char *ansiText = UnicodeToCodePage(cp->j,wText2);
    int len = strlen(ansiText);
    K result = ktn(10,len);
    memcpy(kC(result),ansiText,len);
    delete [] ansiText;
    delete [] wText2;
    return result;
}

K cpToUtf8(K str, K cp) {
    if (str->t != 10) return kerror("str must be string");
    if (cp->t != -7) return kerror("cp must be long");
    wchar_t *wText2 = CodePageToUnicode(cp->j,(char*)kC(str),str->n);
    char *utf8Text = UnicodeToCodePage(65001,wText2);
    int len = strlen(utf8Text);
    K result = ktn(10,len);
    memcpy(kC(result),utf8Text,len);
    delete [] utf8Text;
    delete [] wText2;
    return result;
}

K utf8toANSI(K str) {
    wchar_t *wText2 = CodePageToUnicode(65001,(char*)kC(str),str->n);
    char *ansiText = UnicodeToCodePage(1250,wText2);
    int len = strlen(ansiText);
    K result = ktn(10,len);
    memcpy(kC(result),ansiText,len);
    delete [] ansiText;
    delete [] wText2;
    return result;
}

K winGetSystemTimeAsFileTime(K unused) {
    return kj(winGetSystemTimeAsFileTimeImpl());
}

K winGetFileTime(K fn) {
    if (fn->t != 10) return kerror("winGetFileTime expects string");
    try {
        return kj(winGetFileTimeImpl((char*)kC(fn),fn->n));
    } catch(const std::exception &e) {
        return kerror(e.what());
    }
}

K winSetFileTime(K fn, K time) {
    if (fn->t != 10) return kerror("winSetFileTime: fn must be string");
    if (time->t != -7) return kerror("winGetFileTime: time must be long");
    return kb(winSetFileTimeImpl((char*)kC(fn),fn->n, time->j));
}

K filetimeToTs(uint64_t filetime) {
    return ktj(-KP, 100*(filetime-125911584000000000));
}

K filetimeToTsK(K filetime) {
    if (filetime->t != -7) return kerror("filetimeToTsK expects long");
    return filetimeToTs(filetime->j);
}

K getChinaTime(K unused) {
    return filetimeToTs(getChinaTimeImpl());
}

K bytelistToReal(K input) {
    if (input->t != 4) return kerror("bytelistToReal expects bytelist");
    if (input->n != sizeof(float)) return kerror("bytelistToReal: wrong input size");
    return ke(*(float*)kG(input));
}

K realToBytelist(K input) {
    if (input->t != -8) return kerror("realToBytelist expects real");
    K result = ktn(4,sizeof(float));
    *(float*)kG(result) = input->e;
    return result;
}

K reallistToBytelist(K input) {
    if (input->t != 8) return kerror("reallistToBytelist expects reallist");
    size_t ressize = input->n*sizeof(float);
    K result = ktn(4,ressize);
    memcpy(kG(result), kE(input), ressize);
    return result;
}

K bytelistToFloat(K input) {
    if (input->t != 4) return kerror("bytelistToFloat expects bytelist");
    if (input->n != sizeof(double)) return kerror("bytelistToFloat: wrong input size");
    return kf(*(double*)kG(input));
}

K floatToBytelist(K input) {
    if (input->t != -9) return kerror("floatToBytelist expects float");
    K result = ktn(4,sizeof(double));
    *(double*)kG(result) = input->f;
    return result;
}

K bytelistToIntList(K input) {
    if (input->t != 4) return kerror("bytelistToIntList expects bytelist");
    if (input->n % sizeof(I) != 0) return kerror("bytelistToReal: list size not divisible by 4");
    size_t ressize = input->n / 4;
    K result = ktn(6, ressize);
    for (size_t i = 0; i<ressize; ++i)
        kI(result)[i] = ((I*)kG(input))[i];
    return result;
}

K setReplaceDict(K dict) {
    if (dict->t != 99) return kerror("setReplaceDict expects dictionary");
    K keys = kK(dict)[0];
    K vals = kK(dict)[1];
    if (keys->t != 0) return kerror("setReplaceDict keys must be general list");
    if (vals->t != 0) return kerror("setReplaceDict vals must be general list");
    replaceDict.clear();
    for (int i=0; i<keys->n; ++i) {
        K key = kK(keys)[i];
        K val = kK(vals)[i];
        if (key->t != 10) return kerror("setReplaceDict not all keys are strings");
        if (val->t != 10) return kerror("setReplaceDict not all keys are strings");
        std::string keystr = std::string((char*)&kC(key)[0],key->n);
        std::string valstr = std::string((char*)&kC(val)[0],val->n);
        replaceDict[keystr] = valstr;
    }
    return K(0);
}

void appendNext(std::string &result, std::string &letter) {
    auto it = replaceDict.find(letter);
    if (it == replaceDict.end())
        result += letter;
    else
        result += it->second;
    letter.clear();
}

K textReplace(K text) {
    if (text->t != 10) return kerror("textReplace expects a string");
    std::string result;
    std::string letter;
    int i = 0;
    uint8_t *ptr = &kC(text)[0];
    int len = text->n;
    while (i<len) {
        uint8_t next = *ptr;
        ++ptr;
        if (i>0 && (next<128 || next > 191)) {
            appendNext(result, letter);
        }
        letter += next;
        ++i;
    }
    appendNext(result, letter);
    return kp((char*)result.c_str());
}

K splitToLayers(K matrix) {
    if(matrix->t != 0) return kerror("splitToLayers expects a general list");
    uint32_t max = 0;
    for (size_t i=0; i<matrix->n; ++i) {
        K row = kK(matrix)[i];
        if (row->t != 6) return kerror("splitToLayers expects a matrix of ints");
        for (size_t j=0; j<row->n; ++j) {
            uint32_t item = kI(row)[j];
            if (item > max) max = item;
        }
    }
    size_t layers = 0;
    while (max > 0) {
        layers += 1;
        max >>= 1;
    }
    K result = ktn(0,layers);
    for (size_t layer = 0; layer<layers; ++layer) {
        K layerMatrix = ktn(0,matrix->n);
        kK(result)[layer] = layerMatrix;
        for (size_t i=0; i<matrix->n; ++i) {
            K row = kK(matrix)[i];
            K layerRow = ktn(6,row->n);
            kK(layerMatrix)[i] = layerRow;
            for(size_t j=0; j<row->n; ++j) {
                kI(layerRow)[j] = (kI(row)[j]>>layer)&1;
            }
        }
    }
    return result;
}

K xorDecode(K key, K msg) {
    if (key->t != -4) return kerror("xorDecode: key must be byte");
    if (msg->t != 4) return kerror("xorDecode: msg must be byte list");
    int n = msg->n;
    K result = ktn(4, n);
    uint8_t ky = key->g;
    uint8_t *p = &kG(msg)[0];
    uint8_t *q = p+n;
    uint8_t *r = &kG(result)[0];
    for(;p<q;++p) {
        uint8_t b = *p ^ ky;
        *r = ky = b;
        ++r;
    }
    return knk(2, kg(ky), result);
}

K runProc(K prog, K cmdline) {
    if (prog->t != KC) return kerror("runProc: prog must be string");
    if (cmdline->t != KC) return kerror("runProc: cmdline must be string");
    std::string progstr((char*)&kC(prog)[0], prog->n);
    std::string cmdlinestr((char*)&kC(cmdline)[0], cmdline->n);
    J code;
    std::string out, err;
    std::tie(code, out, err) = runProcImpl(progstr.c_str(), cmdlinestr.c_str());
    return knk(3, ki(code), kpn(out.data(), out.size()), kpn(err.data(), err.size()));
}

K runCoProc(K prog, K cmdline) {
    if (prog->t != KC) return kerror("runProc: prog must be string");
    if (cmdline->t != KC) return kerror("runProc: cmdline must be string");
    std::string progstr((char*)&kC(prog)[0], prog->n);
    std::string cmdlinestr((char*)&kC(cmdline)[0], cmdline->n);
    int pid = (int)runCoProcImpl(progstr.c_str(), cmdlinestr.c_str());
    return ki(pid);
}

}
/*
lib:`$":D:/Projects/c++/qutils/qutils";
utf8toANSI:lib 2:(`utf8toANSI;1)
winGetSystemTimeAsFileTime:lib 2:(`winGetSystemTimeAsFileTime;1)
*/
