#define KXVER 3
#include "k.h"
#include <string>
#include <cstring>
#include <iostream>
#include <fstream>
#include <stdint.h>
#include <zlib.h>
#include <vector>
#include "pklib.h"

namespace {
int32_t sqpNameKey[3*256] = {
    1439053538,46006640,1481339348,696578062,-1232943095,-1848670357,2002426916,1501387941,1511718578,-739652083,852348408,-1316879923,1020134862,-1520626754,-1156907407,-1820939469,-2070977442,-2015077819,1169711127,1583705256,461707925,625138647,-1420953116,1500950171,1815182973,-841142380,1010570213,861606769,832934602,1373961292,-136619217,-1967276479,-1947556236,550941465,-563307875,-978549531,1146773483,-1802138448,511522887,-211998288,-899887398,-1221408587,-36945443,249359382,-1660813650,291885966,-1629383736,-1087131332,1639714300,-281117719,-120269627,-946112876,1512397123,188600842,-1659193949,-811025833,1584230505,-880167119,1036046683,223182462,-1746698453,-17028175,-111470923,665148307,1173497641,1285056048,2087086178,1604585543,-1544461819,2031843172,946550486,1852588015,-950512165,1253866951,1244827547,-822998001,1622707975,-138720369,-2096410222,-1795747348,539297618,966599075,-440368115,-412287067,1649388329,1576088550,-2082424392,-981898245,1249555152,-1168529375,61349452,-851779621,850553740,-1909078733,-1637678871,-1929827643,-2012407573,320492467,785570916,-1305323583,-1604038463,462605198,1928164110,430343664,-2105318269,1121537674,-291776778,1433209706,-1167763302,-568013596,1395826540,-950731125,1346186695,268598180,-743044469,1759939971,177285289,1499439967,184792510,352994756,-1318937394,-436778629,-1972332380,-1205649815,-1902053000,1532467568,-357481704,1260958307,-1233752849,108537975,358378960,-955174084,-132526369,15408488,-687867282,1134451042,-681191717,-888418583,1832670791,-1772853517,212435913,1961673166,-66755658,1118867438,-978089901,-28300053,2068000687,-1022761456,741971928,1131890260,364748076,-311803379,-939568628,-1196851247,1582129356,-1183609583,-635338241,1940661655,982445197,-1400510599,-201755178,-1174504559,253058334,677426909,-2091288629,-1335856074,-1666482325,-1967582842,-1054125591,537415307,1153076909,-1522355920,-2101553724,-864780466,253299160,-635163108,1870469792,-765303674,-1999603682,-1419158323,-94990011,-1258375844,-1102583658,-418743672,-715029086,-1393244047,153625394,501148328,1493990107,-190220697,-1076340987,245857484,-1443343516,-2095490967,-1946483686,-612094116,-688852203,-1485476185,173126713,-1444022109,-653767121,-2106325000,-726891900,158571789,-1279562500,-717633667,1807522496,902185386,-1823697232,-780471529,700889839,-1300902484,-685350178,-1621351100,-1045852299,-644968550,1203592326,1892028582,-1253560620,599377548,1008447078,1767206527,-654117408,1698503003,-563789317,129812140,-957450360,-2146093868,740242880,-639737523,-1110659963,-1261133606,606950555,-1651095658,-1177634430,1509595561,-661099327,-1634680415,29087791,-672020995,-578519366,-2009255843,636563794,1251109197,2012341761,-2145065241,44430653,-1673595687,-1354744628,-491977792,1190000364,1872483302,-870011526,1202694930,-2111205897,1888263916,
    1996014001,-1282123310,1058940633,-511632409,1458379853,-909014280,-400030194,-1848976850,1556871607,-240823596,1016939331,-520059003,719318719,-117292896,1023986919,1114533808,1463588943,329794478,1080783929,1667270105,1342225050,-1387640917,-1358946931,1100548014,408719254,-437654195,1635139891,-747618921,-1399263034,-607935620,-2047864636,-1874256334,-248637249,-930310431,-738470183,-473789688,-708900660,-1310226343,625401295,-1338985984,-1426249711,1437740321,-745802393,1184660011,1523603346,-1582983138,2113635204,886163978,2125519840,-702750474,964716727,-431985377,-1783731385,-467135952,-1333514143,-1492501912,-482281947,1927069693,-1900498995,414606879,401562204,809762,1805727798,1634067331,1950882907,-445708527,-1569763292,1609707104,832956457,-1593226256,-964629396,-1930221609,-336513910,1780645167,1946571140,-1913237230,733808110,-456126762,696315418,1793186419,-398060326,1821968043,-812776741,-747487593,-1829344081,-1400598073,-1362733418,-1182165041,-99170462,1836303967,542974630,1305717413,770403264,-1623758740,1906649131,929806816,2147428891,-563636177,-1665190962,778939191,1848911033,249643964,-2094374695,-1151129119,334937853,1499855748,-167042244,1030312323,1127359649,-1244017947,-2109367381,-1625181423,-1351855545,-1270369990,2066118339,-1014400563,-2061062619,-984568485,1750112679,1709818557,-439952330,-519358551,-2013173640,-830352156,618069120,1090917677,1833918352,-992185154,-616011924,1823828407,-205563505,69929177,46969566,-1325043867,1201228532,-99345500,-1820939474,128411447,1978132220,1151172769,62334365,-153143926,1517671865,1193830691,991572207,-289522326,-1649300992,8032473,610693233,27030479,1761844173,-1785723068,1696117227,1761997314,-298233422,-515769175,2038409266,1519773019,-702137579,1533146004,-1988441316,6259625,574754673,-191555730,2115211069,328393604,926676906,-1907283946,-1453280310,74766156,-5450025,787869086,1620650666,2120814233,599815325,-656240379,1432181001,358816766,-1499702756,1343231946,-1723629496,947075783,-427629880,-731553834,-1787933692,880670275,793450363,-1813169500,-1484907051,2061850370,-760926247,-276061812,-1210859026,-2139571571,-1420121381,1965809807,109785537,126529084,-1436908733,306025064,753593923,-1900170695,1694650867,76035656,-1939676882,313729383,-451858790,268445000,1048215949,125719335,-247411679,1827133277,-1684407899,840266780,-1230316626,1938254044,-2103217105,1985048608,-578344232,-1660353870,2098883332,1228412306,1671844517,202761766,-500207402,31998853,-1298276044,549781518,-379456445,758212142,1021754408,888790420,-96084397,1232439485,-1805115045,125303388,1869681856,-521656684,-466151034,1460743650,-523582839,-224145696,1782702521,-1076975747,-114819758,1769242008,-1096323877,-1915513513,81485518,705201608,1004857582,567772636,165575694,844687923,1368533378,-292696028,
    1039570525,817963899,-134846358,-1616076410,2084569206,-2052264054,-189345248,-574404580,1134472900,1903935075,-2108032345,-696074904,-1825929712,952044159,1645404871,-1997655704,-1279102905,1630784286,355030278,1525047878,488672733,-1457701446,-1021995379,1789027915,1902972106,-1994438314,-2138674177,-1118386105,-1869397414,685612679,-2064695800,1762281942,1786707842,-1412439040,1027335626,941319436,1266452002,1040336627,-1554639276,-1802992036,988748786,1583179938,-751886884,1368861680,393879867,1184069058,929303504,-63757112,118037001,761517051,559149091,1210202229,1638225958,-1944885960,1240931736,-2067278562,-2058020237,332793029,-687757786,-2017966902,1948168861,707565436,-946353661,1816167895,766310299,1934598891,-869726889,-98667036,112368167,-1093784966,1889817931,-919235538,-1486570559,535007702,2013786306,1080061657,-451596154,-383943214,-312656983,-1441483190,-2085466663,-333449779,-1171002669,-454069412,-1140448200,-658516701,1195187716,537393319,-1339489299,-2031449382,-1783928369,-48261111,-1665935173,1374968152,-1663221130,-1035631010,-1895005333,1323817991,-164196963,-282321471,-296307381,-1117598161,-191796563,-937642604,1098030921,616493220,-554399831,573441464,-1925450298,297095177,-1391865165,433823697,-683511675,870055051,1382781816,2030967752,-1298560512,-1520167165,108450377,1804699084,820262031,-2101006491,1472715812,1218191053,-1614106582,1456869655,-24732500,1442599232,2143007618,-1638204295,268729497,-56665724,1448640045,-1182690320,-1728160114,699489131,-1788743595,-1156797915,508480533,603273531,138785880,-822122550,-1332113396,11621967,971961297,-54411388,-1400335435,1686421262,-1849677133,-1945367440,1752148166,-512639274,-542230561,-710826777,-471119455,1583355104,542843308,-44518438,779880397,-282277798,-682067130,-199785347,-1976512831,1889029996,-256494712,-1038038643,-303683274,-1832867917,519270888,537261999,-1851493787,-1328589564,-721376344,-883143725,-1690580029,-815381323,-829126417,4180334,-1438506449,1212478416,1303944567,141040302,1714371112,1981108955,502767994,-1812009574,-867603889,-1575497779,1000589616,646938231,127382689,-1947468719,109654212,382235874,-1035806172,-81617034,-1602659582,1755299894,396834610,-769987584,-1409243502,1528921880,-1371400668,734026944,1220664186,1330537396,375910478,872550292,-1758780075,-1710803621,23484784,2109082735,987172923,1547504064,-291251494,-2000544752,270808791,1782264832,-346932148,-73934698,-1773356949,-578322376,86628941,185886885,410229448,-135109016,-162577295,1544877507,1151369723,967605815,-1978154389,-2037424537,959551373,1860139031,1230097511,-1808529421,-866225009,729737001,-877453072,301910247,-53492136,54870868,926589420,492371610,105320622,-1467309894,-779902402,1087459491,-181290799,-1478910075,293833941,-1315019597,1030202857,-1339270458,-1715881496,1277176698
};

uint32_t encryptFileName(const char *fn, uint32_t length, uint32_t mode) {
    uint32_t ebx =  0x7FED7FED;
    uint32_t esi =  0xEEEEEEEE;
    if (mode >= 3) throw "mode==3 nyi";
    uint32_t modeOffset = 256*mode;
    for (size_t i=0; i<length; ++i) {
        int32_t eax = int(std::toupper(fn[i]));
        ebx = (ebx + esi) ^ sqpNameKey[modeOffset+eax];
        esi = esi * 33 + eax + ebx + 3;
    }
    return ebx;
}

int32_t sqpKey[256] = {
    423274136,1419179989,1107858203,2051081964,-2081920960,-191139956,-1170367919,1442139613,769987442,-1694804197,984830982,-1385890017,-948476674,2139505766,1097702612,-1572302216,-485783836,189936054,-1167610154,-441768857,1610779536,496902342,712796458,1802050779,-1638795241,-1686749716,1026110015,-807326872,1967867291,-1574731705,-641379052,1809645505,1765696320,-2110242841,420932191,-327430823,1927157338,-409332201,-1899470284,-1460612476,550044198,2079950980,681935665,1053031022,1289783643,-1017924400,871302735,568713744,-927246179,-396506446,-1402633569,-1480617264,94771021,631573550,-439908489,1031078431,1269472408,599640196,-1772897321,-1159927819,-1031560060,-1069490386,-1821333439,791765026,921621041,-1406354420,331392155,-841930345,134123954,-847336499,738273053,407055864,1503423431,1978219866,-1233490206,-1905029610,-7310339,-1351155094,-126967044,-1856987485,866618822,1333338954,980759996,892992689,822341202,1332682345,1806953404,1287091541,-1915623015,719209373,290594734,-1186126523,-1914791235,420034879,-1215126979,1956398427,-1246359764,939809230,229464096,-1322220453,689749330,-560309321,1373567329,1364943880,-898727362,942567028,-289522319,1284443242,-428417814,350346364,1870644788,-813323965,-744576658,326007955,1902424836,-215018701,901988404,-566634719,-1851231175,-1005580001,703691436,320251647,317822190,1108055193,-148000548,1762369427,399592370,-1886184776,561316028,-2024533000,-1733106627,-987785871,1422835146,119131257,-205060083,-467114127,-1544899635,1248526560,298780505,2122937209,1530038124,1586287862,216922724,-1852128569,-1307249741,243909516,-255575495,-354351838,-2091135482,-1628683326,-366564906,1767053345,1730523722,-629034782,-709579213,135240187,363347375,702531360,-1847488497,672546136,-2083453022,1319900314,-1619928552,1641399546,-475321761,-944712129,-1278446294,1642844086,654292266,-310862273,-1438922408,1163560840,-910130519,169602830,-1030071682,353191733,-1808266784,1763792144,-284488279,995008435,-659173300,-945806424,-1328217464,1686246261,-1033836337,-2070495956,-11578315,263542284,2094484050,-1822909312,-2003346361,-2084722531,-1949547882,28847137,-41804353,642911047,77086233,-740177369,2016172047,846198131,-1051214649,1331587972,1156316155,-634988072,1826214030,387576280,1901855879,741162130,1408936873,-1132240570,1359778518,-527828950,1182799647,916390110,1894523697,237321557,-621045993,-438463955,-1785635551,-1608503402,-1587426233,-355490063,-312569463,-625445244,-1531482806,-93304681,1662980282,-744642311,1572126948,385737770,771716480,-1250956162,-1006652560,-1905314116,1620563033,1364024630,-1515767838,964147635,-47079222,-1875679013,-399045279,-1743743712,-1377682260,-1711788540,1105100451,-2069773675,152640480,814943490,480224330,-1006192937,-287530670,1632207004,-1341546764,-973712475,1276147981,1929586796
};

//srcbuf may be the same as dstbuf
int decryptBlock(void *srcbuf, void *dstbuf, uint32_t size, uint32_t encrKey) {
    uint32_t *sbufptr = (uint32_t *)srcbuf;
    uint32_t *dbufptr = (uint32_t *)dstbuf;
    uint32_t state1 = 0xeeeeeeee;
    uint32_t state2 = encrKey;
    if (size == 0) return 0;
    uint32_t counter = size >> 2;
    if (counter == 0) return 0;
    while(counter > 0) {    //EDI
        uint32_t tmp1 = state1; //EAX
        uint32_t tmp2 = state2; //EDX
        uint32_t tmp3 = *sbufptr;    //ESI
        uint32_t tmp4 = sqpKey[tmp2 & 0xff];
        uint32_t tmp5 = (tmp1+tmp2+tmp4) ^ tmp3;
        --counter;
        *dbufptr = tmp5;
        ++sbufptr;
        ++dbufptr;
        state1 = ((tmp1+tmp4)+(((tmp1+tmp4) << 5)+tmp5)+3);
        state2 = ((tmp2 >> 0x0b) | ((~tmp2 << 0x15)+0x11111111));
    }
    return 1;
}

struct SqpHeader {
    uint32_t magic;
    uint32_t headerSize;
    uint32_t fileSize;
    uint32_t hashTableOffset;
    uint32_t blockTableOffset;
    uint32_t hashTableSize;
    uint32_t blockTableSize;
    uint16_t unknown1;
    uint8_t stride;
    uint8_t unknown2;
};

struct SqpHashEntry {
    uint32_t unknown1;
    int32_t blockindex;
    uint32_t fileNameHash1;
    uint32_t fileNameHash2;
};

struct SqpBlockEntry {
    uint32_t offset;
    uint32_t flags;
    uint32_t unknown1;
    uint32_t uncompressedSize;
};

struct SqpReadWriteBuf {
    const std::vector<uint8_t> &src;
    std::vector<uint8_t> dst;
    uint32_t srcIndex = 0;
    uint32_t srcSize = 0;
    uint32_t dstIndex = 0;
    SqpReadWriteBuf(const std::vector<uint8_t> &src_) : src(src_) {}
    void newData(uint32_t offset, uint32_t size) {
        srcIndex = offset+1;
        srcSize = size;
        dstIndex = 0;
    }   //ignore "08" byte at the start of each chunk
};

unsigned int sqpRead(char *data, unsigned int *size, void *param) {
    SqpReadWriteBuf &buf = *(SqpReadWriteBuf*)param;
    uint32_t toCopy = std::min(*size,buf.srcSize-buf.srcIndex);
    memcpy(data, &buf.src[buf.srcIndex], toCopy);
    buf.srcIndex += toCopy;
    return toCopy;
}

void sqpWrite(char *data, unsigned int *size, void *param) {
    SqpReadWriteBuf &buf = *(SqpReadWriteBuf*)param;
    uint32_t toCopy = *size;
    if (buf.dst.size() < buf.dstIndex+toCopy)
        buf.dst.resize(buf.dst.size()+toCopy);
    memcpy(&buf.dst[buf.dstIndex], data, toCopy);
    buf.dstIndex += toCopy;
}

std::vector<uint8_t> extractFileHTI(int &errorCode, const std::string &sqpName, uint32_t blockIndex, uint32_t stride,
    const SqpBlockEntry *blockTable, uint32_t blockTableSize) {
    errorCode = 0;
    std::ifstream f(sqpName, std::ios::binary);
    if(f.fail()) {
        errorCode = 1;
        return std::vector<uint8_t>();
    }

    uint32_t fullsize = blockTable[blockIndex].uncompressedSize;
    uint32_t fileBlockSize = 512 << stride;
    uint32_t fileBlockCount = (fullsize/fileBlockSize) + (fullsize%fileBlockSize != 0);
    std::vector<uint32_t> fileBlockBounds(fileBlockCount+1);
    f.seekg(blockTable[blockIndex].offset);
    f.read((char*)&fileBlockBounds[0], 4*fileBlockBounds.size());
    std::vector<uint8_t> result(fullsize);
    uint32_t resultPtr = 0;
    uint32_t totalCompressedSize = fileBlockBounds[fileBlockCount]-fileBlockBounds[0];
    std::vector<uint8_t> compressedData(totalCompressedSize);
    f.seekg(blockTable[blockIndex].offset+fileBlockBounds[0]);
    f.read((char*)&compressedData[0],totalCompressedSize);
    std::vector<uint8_t> workBuf(CMP_BUFFER_SIZE);
    SqpReadWriteBuf rwbuf(compressedData);
    for (uint32_t i = 0; i<fileBlockCount; ++i) {
        uint32_t origSize = (i == fileBlockCount-1 ? fullsize % fileBlockSize : fileBlockSize);
        uint32_t currentBlockSize = fileBlockBounds[i+1]-fileBlockBounds[i];
        if (origSize == currentBlockSize) {
            memcpy((char*)&result[resultPtr], (char*)&compressedData[fileBlockBounds[i]-fileBlockBounds[0]], currentBlockSize);
            resultPtr += currentBlockSize;
        } else {
            rwbuf.newData(fileBlockBounds[i]-fileBlockBounds[0], fileBlockBounds[i+1]-fileBlockBounds[0]);
            int cmpres = explode(sqpRead, sqpWrite, (char*)&workBuf[0], &rwbuf);
            if (cmpres != CMP_NO_ERROR) {
                std::cerr << "compression result: " << cmpres;
                errorCode = 3;
                return std::vector<uint8_t>();
            }
            memcpy((char*)&result[resultPtr], (char*)&rwbuf.dst[0], rwbuf.dstIndex);
            resultPtr += rwbuf.dstIndex;
        }
    }
    return result;
}

std::vector<uint8_t> extractFileHT(int &errorCode, const std::string &sqpName, const std::string &fileName, uint32_t stride,
    const SqpHashEntry *hashTable, uint32_t hashTableSize, const SqpBlockEntry *blockTable, uint32_t blockTableSize) {
    errorCode = 0;
    std::ifstream f(sqpName, std::ios::binary);
    if(f.fail()) {
        errorCode = 1;
        return std::vector<uint8_t>();
    }

    uint32_t hash0 = encryptFileName(fileName.c_str(),fileName.size(),0);
    uint32_t hash1 = encryptFileName(fileName.c_str(),fileName.size(),1);
    uint32_t hash2 = encryptFileName(fileName.c_str(),fileName.size(),2);
    uint32_t hashindex = hash0 % hashTableSize;
    uint32_t origblock1index = hashindex;
    bool found = false;
    while(true) {
        if (hashTable[hashindex].blockindex == -1) {
            break;
        }
        if (hashTable[hashindex].fileNameHash1 == hash1 &&
            hashTable[hashindex].fileNameHash2 == hash2) {
            found = true;
            break;
        }
        hashindex = (hashindex+1) % hashTableSize;
        if (hashindex == origblock1index) break;
    }
    if(!found) {
        errorCode = 2;
        return std::vector<uint8_t>();
    }

    uint32_t blockindex = hashTable[hashindex].blockindex;
    return extractFileHTI(errorCode, sqpName, blockindex, stride, blockTable, blockTableSize);
}

std::vector<uint8_t> extractFile(int &errorCode, const std::string &sqpName, const std::string &fileName) {
    errorCode = 0;
    std::ifstream f(sqpName, std::ios::binary);
    if(f.fail()) {
        errorCode = 1;
        return std::vector<uint8_t>();
    }
    SqpHeader header;
    f.read((char*)&header,32);

    std::vector<SqpHashEntry> hashTable(header.hashTableSize);
    f.seekg(header.hashTableOffset);
    f.read((char*)&hashTable[0],header.hashTableSize*16);
    decryptBlock(&hashTable[0],&hashTable[0],header.hashTableSize*16,0xC3AF3770);

    std::vector<SqpBlockEntry> blockTable(header.blockTableSize);
    f.seekg(header.blockTableOffset);
    f.read((char*)&blockTable[0],header.blockTableSize*16);
    decryptBlock(&blockTable[0],&blockTable[0],header.blockTableSize*16,0xEC83B3A3);

    return extractFileHT(errorCode, sqpName, fileName, header.stride, &hashTable[0], header.hashTableSize, &blockTable[0], header.blockTableSize);
}

}   //namespace

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

K k_sqp_encryptFileName(K fileName, K mode) {
    if (fileName->t != 10) return kerror("encryptFileName: fileName must be string");
    if (mode->t != -7) return kerror("encryptFileName: mode must be long");
    return ki(encryptFileName((char*)kG(fileName),fileName->n,mode->j));
}

K k_sqp_decryptBlock(K block, K key) {
    if (block->t != 4) return kerror("decryptBlock: block must be bytelist");
    if (key->t != -6) return kerror("decryptBlock: key must be int");
    K result = ktn(4,block->n);
    decryptBlock(kG(block), kG(result), block->n, key->i);
    return result;
}

K k_sqp_extractFile(K sqpName, K fileName) {
    if (sqpName->t != 10) return kerror("extractFile: sqpName must be string");
    if (fileName->t != 10) return kerror("extractFile: fileName must be string");
    int errorCode;
    std::vector<uint8_t> extracted = extractFile(errorCode, std::string((char*)kC(sqpName),sqpName->n), std::string((char*)kC(fileName),fileName->n));
    switch(errorCode) {
        case 1:return kerror("SQP file not found");
        case 2:return kerror("file not found inside SQP");
        case 3:return kerror("decompression error");
    }
    K result = ktn(10,extracted.size());
    memcpy(kG(result), (char*)&extracted[0], extracted.size());
    return result;
}

K k_sqp_loadTables(K sqpName) {
    if (sqpName->t != 10) return kerror("extractFile: sqpName must be string");

    std::string sqpNameStr =std::string((char*)kC(sqpName),sqpName->n);
    std::ifstream f(sqpNameStr, std::ios::binary);
    if(f.fail()) return kerror("can't open SQP file");
    SqpHeader header;
    f.read((char*)&header,32);
    K hashTable = ktn(4,header.hashTableSize*16);
    K blockTable = ktn(4,header.blockTableSize*16);

    f.seekg(header.hashTableOffset);
    f.read((char*)kG(hashTable),header.hashTableSize*16);
    decryptBlock(kG(hashTable),kG(hashTable),header.hashTableSize*16,0xC3AF3770);

    f.seekg(header.blockTableOffset);
    f.read((char*)kG(blockTable),header.blockTableSize*16);
    decryptBlock(kG(blockTable),kG(blockTable),header.blockTableSize*16,0xEC83B3A3);

    return knk(3,kj(header.stride), hashTable,blockTable);
}

K k_sqp_extractFileHT(K sqpName, K fileName, K tables) {   //extract file, user provides the hash and block tables
    if (sqpName->t != 10) return kerror("extractFileHT: sqpName must be string");
    if (fileName->t != 10) return kerror("extractFileHT: fileName must be string");
    if (tables->t != 0) return kerror("extractFileHT: tables must be general list");
    if (tables->n != 3) return kerror("extractFileHT: tables must have exactly 2 elements");
    K stride = kK(tables)[0];
    K hashTable = kK(tables)[1];
    K blockTable = kK(tables)[2];
    if (stride->t != -7) return kerror("extractFileHT: stride must be long");
    if (hashTable->t != 4) return kerror("extractFileHT: hashTable must be byte list");
    if (blockTable->t != 4) return kerror("extractFileHT: blockTable must be byte list");

    int errorCode;
    std::vector<uint8_t> extracted = extractFileHT(errorCode, std::string((char*)kC(sqpName),sqpName->n), std::string((char*)kC(fileName),fileName->n),
        stride->j, (SqpHashEntry*)kG(hashTable), hashTable->n/16, (SqpBlockEntry*)kG(blockTable), blockTable->n/16);
    switch(errorCode) {
        case 1:return kerror("SQP file not found");
        case 2:return kerror("file not found inside SQP");
        case 3:return kerror("decompression error");
    }
    K result = ktn(10,extracted.size());
    memcpy(kG(result), (char*)&extracted[0], extracted.size());
    return result;
}

K k_sqp_extractFileHTI(K sqpName, K blockIndex, K tables) {   //extract file, user provides the hash and block tables and index in the block table
    if (sqpName->t != 10) return kerror("extractFileHTI: sqpName must be string");
    if (tables->t != 0) return kerror("extractFileHTI: tables must be general list");
    if (tables->n != 3) return kerror("extractFileHTI: tables must have exactly 2 elements");
    if (blockIndex->t != -7) return kerror("extractFileHTI: blockIndex must be long");
    K stride = kK(tables)[0];
    K hashTable = kK(tables)[1];
    K blockTable = kK(tables)[2];
    if (stride->t != -7) return kerror("extractFileHT: stride must be long");
    if (hashTable->t != 4) return kerror("extractFileHT: hashTable must be byte list");
    if (blockTable->t != 4) return kerror("extractFileHT: blockTable must be byte list");

    int errorCode;
    std::vector<uint8_t> extracted = extractFileHTI(errorCode, std::string((char*)kC(sqpName),sqpName->n), blockIndex->j,
        stride->j, (SqpBlockEntry*)kG(blockTable), blockTable->n/16);
    switch(errorCode) {
        case 1:return kerror("SQP file not found");
        case 2:return kerror("file not found inside SQP");
        case 3:return kerror("decompression error");
    }
    K result = ktn(10,extracted.size());
    memcpy(kG(result), (char*)&extracted[0], extracted.size());
    return result;
}

}
