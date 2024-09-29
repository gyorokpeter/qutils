void initTZImpl();

wchar_t *CodePageToUnicode(int codePage, const char *src, int srcLen);
char *UnicodeToCodePage(int codePage, const wchar_t *src, int srcLen = 0);

uint64_t winGetSystemTimeAsFileTimeImpl();
uint64_t winGetFileTimeImpl(const char *fileName, uint32_t length);
bool winSetFileTimeImpl(const char *fileName, uint32_t length, uint64_t fileTime);

uint64_t getChinaTimeImpl();
std::tuple<int,std::string,std::string> runProcImpl(std::string externalProgram, std::string arguments);
void *runCoProcImpl(std::string externalProgram, std::string arguments);
void sleepImpl(uint32_t msec);
