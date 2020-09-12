#include <windows.h>
#include <stdio.h>

using namespace std;

// 65001 is utf-8.
wchar_t *CodePageToUnicode(int codePage, const char *src, int srcLen)
    {
    if (!src) return 0;
    if (!srcLen)
    {
    wchar_t *w = new wchar_t[1];
    w[0] = 0;
    return w;
    }
    
    int requiredSize = MultiByteToWideChar(codePage,
        0,
        src,srcLen,0,0);
    
    if (!requiredSize)
        {
        return 0;
        }
    
    wchar_t *w = new wchar_t[requiredSize+1];
    w[requiredSize] = 0;
    
    int retval = MultiByteToWideChar(codePage,
        0,
        src,srcLen,w,requiredSize);
    if (!retval)
        {
        delete [] w;
        return 0;
        }
    
    return w;
    }
    
char *UnicodeToCodePage(int codePage, const wchar_t *src)
    {
    if (!src) return 0;
    int srcLen = wcslen(src);
    if (!srcLen)
    {
    char *x = new char[1];
    x[0] = '\0';
    return x;
    }
    
    int requiredSize = WideCharToMultiByte(codePage,
        0,
        src,srcLen,0,0,0,0);
    
    if (!requiredSize)
        {
        return 0;
        }
    
    char *x = new char[requiredSize+1];
    x[requiredSize] = 0;
    
    int retval = WideCharToMultiByte(codePage,
        0,
        src,srcLen,x,requiredSize,0,0);
    if (!retval)
        {
        delete [] x;
        return 0;
        }
    
    return x;
    }
