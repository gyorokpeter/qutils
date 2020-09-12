#define KXVER 3
#include "k.h"
#include <cstring>

wchar_t *CodePageToUnicode(int codePage, const char *src, int srcLen);
char *UnicodeToCodePage(int codePage, const wchar_t *src);

extern "C" {

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

}
