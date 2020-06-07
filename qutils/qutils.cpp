#include <windows.h>
#include <stdio.h>
#include <stdint.h>
#include <string>
#include <iostream>
#include <sstream>

using namespace std;

namespace {
    TIME_ZONE_INFORMATION chinaTZ = {0};
};

template<class ... Ts>
string cat(Ts ... args) {
    ostringstream os;
    auto a = { (os << args, 0)... };
    if (sizeof(a) != sizeof(a)){}   //swallow the "unused variable" warning
    return os.str();
}

string niceGetLastError() {
    int errcode = GetLastError();
    char buffer[256];
    memset(buffer, 0, 256);
    FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, errcode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), buffer, 255, 0);
    return cat("(", errcode,") ",buffer);
}

struct STimeZoneFromRegistry
{
    long  Bias;
    long  StandardBias;
    long  DaylightBias;
    SYSTEMTIME StandardDate;
    SYSTEMTIME DaylightDate;
};

void initTZImpl() {
    STimeZoneFromRegistry binary_data;
    DWORD size = sizeof(binary_data);
    HKEY hk = NULL;
    RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones", 0, KEY_ENUMERATE_SUB_KEYS, &hk);
    bool found = false;
    string foundStr;
    DWORD index = 0;
    while(true) {
        char name[256];
        DWORD nameL = 256;
        LONG result = RegEnumKeyEx(hk, index, name, &nameL, 0, 0, 0, 0);
        if (result != ERROR_SUCCESS) break;
        string tzname = name;
        if (tzname.find("China") != string::npos) {
            found = true;
            foundStr = name;
            break;
        }
        index += 1;
    }
    RegCloseKey(hk);

    string zone_key = string("SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones\\")+foundStr;
    if ((RegOpenKeyEx(HKEY_LOCAL_MACHINE, zone_key.c_str(), 0, KEY_QUERY_VALUE, &hk) == ERROR_SUCCESS)
        && (RegQueryValueEx(hk, "TZI", NULL, NULL, (BYTE *) &binary_data, &size) == ERROR_SUCCESS))
    {
        chinaTZ.Bias = binary_data.Bias;
        chinaTZ.DaylightBias = binary_data.DaylightBias;
        chinaTZ.DaylightDate = binary_data.DaylightDate;
        chinaTZ.StandardBias = binary_data.StandardBias;
        chinaTZ.StandardDate = binary_data.StandardDate;
    }
    RegCloseKey(hk);
}

uint64_t getChinaTimeImpl() {
    SYSTEMTIME time;
    GetSystemTime(&time);
    SYSTEMTIME chinatime;
    SystemTimeToTzSpecificLocalTime(&chinaTZ, &time, &chinatime);
    FILETIME ft;
    SystemTimeToFileTime(&chinatime, &ft);
    return (uint64_t(ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
}

uint64_t winGetSystemTimeAsFileTimeImpl() {
    FILETIME ft;
    GetSystemTimeAsFileTime(&ft);
    return (uint64_t(ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
}

uint64_t winGetFileTimeImpl(const char *fileName, uint32_t length) {
    FILETIME ft;
    ft.dwLowDateTime = 0;
    ft.dwHighDateTime = 0x80000000;
    string fn = string(fileName,length);
    HANDLE fh = CreateFile(string(fileName,length).c_str(),
        GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING,
        0, 0);
    if (fh == INVALID_HANDLE_VALUE) {
        fh = CreateFile (fn.c_str(),
                                GENERIC_WRITE,
                                FILE_SHARE_READ|FILE_SHARE_DELETE|FILE_SHARE_WRITE,
                                NULL,
                                OPEN_EXISTING,
                                FILE_FLAG_BACKUP_SEMANTICS,
                                NULL
                             );
    }
    if(fh == INVALID_HANDLE_VALUE) {
        cout << fn << ": " << niceGetLastError() << endl;
    }
    GetFileTime(fh, 0, 0, &ft);
    CloseHandle(fh);
    return (uint64_t(ft.dwHighDateTime) << 32) + ft.dwLowDateTime;
}

bool winSetFileTimeImpl(const char *fileName, uint32_t length, uint64_t fileTime) {
    FILETIME ft;
    ft.dwLowDateTime = fileTime & 0xffffffff;
    ft.dwHighDateTime = fileTime >> 32;
    HANDLE fh = CreateFile(string(fileName,length).c_str(),
        FILE_WRITE_ATTRIBUTES, FILE_SHARE_WRITE, 0, OPEN_EXISTING,
        0, 0);
    bool res = SetFileTime(fh, 0, 0, &ft);
    if (!res)
        cout << niceGetLastError() << endl;
    CloseHandle(fh);
    return res;
}

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
    
char *UnicodeToCodePage(int codePage, const wchar_t *src, int srcLen = 0)
    {
    if (!src) return 0;
    if (srcLen == 0) srcLen = wcslen(src);
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
