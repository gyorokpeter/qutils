#include <windows.h>
#include <stdio.h>
#include <stdint.h>
#include <string>
#include <iostream>
#include <sstream>
#include <tuple>

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
        std::string err = niceGetLastError();
        throw std::runtime_error(err);
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

struct streamThreadParams {
    HANDLE h;
    std::string str;
};

DWORD __stdcall readDataFromExtProgram(void *params)
{
    const int BUFSIZE = 4096;
    HANDLE h = ((streamThreadParams*)params)->h;
    std::string &str = ((streamThreadParams*)params)->str;
    DWORD dwRead;
    CHAR chBuf[BUFSIZE];
    BOOL bSuccess = FALSE;

    for (;;)
    {
        bSuccess = ReadFile(h, chBuf, BUFSIZE, &dwRead, NULL);
        if (!bSuccess) {
            int err=GetLastError();
            if (err == ERROR_OPERATION_ABORTED || err == ERROR_BROKEN_PIPE) break;
            continue;
        }
        if (dwRead == 0) continue;
        str.append(chBuf, dwRead);

        if (!bSuccess) break;
    }
    return 0;
}

std::tuple<int,std::string,std::string> runProcImpl(std::string externalProgram, std::string arguments)
{

    HANDLE pipeOutRd = NULL;
    HANDLE pipeOutWr = NULL;
    HANDLE pipeErrRd = NULL;
    HANDLE pipeErrWr = NULL;
    HANDLE readStdoutThread = NULL;
    HANDLE readStderrThread = NULL;
    PROCESS_INFORMATION pi;

    streamThreadParams streamOut;
    streamThreadParams streamErr;
    STARTUPINFO si;
    SECURITY_ATTRIBUTES saAttr;

    ZeroMemory(&saAttr, sizeof(saAttr));
    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;

    if (!CreatePipe(&pipeOutRd, &pipeOutWr, &saAttr, 0))
    {
        throw std::runtime_error(niceGetLastError());
    }

    if (!SetHandleInformation(pipeOutRd, HANDLE_FLAG_INHERIT, 0))
    {
        throw std::runtime_error(niceGetLastError());
    }

    if (!CreatePipe(&pipeErrRd, &pipeErrWr, &saAttr, 0))
    {
        throw std::runtime_error(niceGetLastError());
    }

    if (!SetHandleInformation(pipeErrRd, HANDLE_FLAG_INHERIT, 0))
    {
        throw std::runtime_error(niceGetLastError());
    }

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.hStdError = pipeErrWr;
    si.hStdOutput = pipeOutWr;
    si.dwFlags |= STARTF_USESTDHANDLES;

    ZeroMemory(&pi, sizeof(pi));

    std::string commandLine = externalProgram + " " + arguments;

    // Start the child process.
    if (!CreateProcessA(NULL,           // No module name (use command line)
        (TCHAR*)commandLine.c_str(),    // Command line
        NULL,                           // Process handle not inheritable
        NULL,                           // Thread handle not inheritable
        TRUE,                           // Set handle inheritance
        0,                              // No creation flags
        NULL,                           // Use parent's environment block
        NULL,                           // Use parent's starting directory
        &si,                            // Pointer to STARTUPINFO structure
        &pi)                            // Pointer to PROCESS_INFORMATION structure
        )
        throw std::runtime_error(niceGetLastError());
    streamOut.h = pipeOutRd;
    streamErr.h = pipeErrRd;
    readStdoutThread = CreateThread(0, 0, readDataFromExtProgram, &streamOut, 0, NULL);
    readStderrThread = CreateThread(0, 0, readDataFromExtProgram, &streamErr, 0, NULL);
    WaitForSingleObject(pi.hProcess, INFINITE);
    DWORD exitCode;
    GetExitCodeProcess(pi.hProcess, &exitCode);
    CloseHandle(pipeOutWr);
    CloseHandle(pipeErrWr);
    WaitForSingleObject(readStdoutThread, INFINITE);
    WaitForSingleObject(readStderrThread, INFINITE);
    return {exitCode, streamOut.str, streamErr.str};
}

void *runCoProcImpl(std::string externalProgram, std::string arguments)
{
    PROCESS_INFORMATION pi;
    STARTUPINFO si;

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);

    ZeroMemory(&pi, sizeof(pi));

    std::string commandLine = externalProgram + " " + arguments;

    // Start the child process.
    if (!CreateProcessA(NULL,           // No module name (use command line)
        (TCHAR*)commandLine.c_str(),    // Command line
        NULL,                           // Process handle not inheritable
        NULL,                           // Thread handle not inheritable
        TRUE,                          // Set handle inheritance
        0,                              // No creation flags
        NULL,                           // Use parent's environment block
        NULL,                           // Use parent's starting directory
        &si,                            // Pointer to STARTUPINFO structure
        &pi)                            // Pointer to PROCESS_INFORMATION structure
        )
        throw std::runtime_error(niceGetLastError());
    return pi.hProcess;
}

void sleepImpl(uint32_t msec) {
    Sleep(msec);
}
