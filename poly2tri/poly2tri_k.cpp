#define KXVER 3
#include "poly2tri.h"
#include "k.h"
#include <vector>
#include <cstring>
#include <stdint.h>
#include <iostream>
#include <unordered_map>
#include <queue>

extern "C" {

K kerror(const char *err) {
    return krr(const_cast<S>(err));
}

K poly2tri(K poly, K holes) {
    if (poly->t != 0) return kerror("poly must be a general list");
    for (size_t i=0; i<poly->n; ++i) {
        K edge = kK(poly)[i];
        if (edge->t != 9) return kerror("poly must contain only float lists");
        if (edge->n != 2) return kerror("poly must contain only float lists of length 2");
    }
    if (holes->t != 0) return kerror("holes must be a general list");
    for (size_t i=0; i<holes->n; ++i) {
        K hole = kK(holes)[i];
        if (hole->t != 0) return kerror("holes must contain only general lists");
        for (size_t j=0; j<hole->n; ++j) {
            K edge = kK(hole)[j];
            if (edge->t != 9) return kerror("holes must contain only lists of float lists");
            if (edge->n != 2) return kerror("holes must contain only lists of float lists of length 2");
        }
    }

    std::vector<p2t::Point*> polyV;
    std::vector<std::vector<p2t::Point*>> holesV;

    for (size_t i=0;i<poly->n; ++i) {
        K edge = kK(poly)[i];
        //std::cout << "pt: " << kF(edge)[0] << " " << kF(edge)[1] << std::endl;
        polyV.push_back(new p2t::Point(kF(edge)[0], kF(edge)[1]));
    }
    for (size_t i=0;i<holes->n; ++i) {
        std::vector<p2t::Point*> holeV;
        K hole = kK(holes)[i];
        for (size_t j=0; j<hole->n; ++j) {
            K edge = kK(hole)[j];
            holeV.push_back(new p2t::Point(kF(edge)[0], kF(edge)[1]));
        }
        holesV.push_back(holeV);
    }
    p2t::CDT cdt(polyV);
    for (std::vector<p2t::Point*> &holeV : holesV) {
        cdt.AddHole(holeV);
    }

    cdt.Triangulate();

    //std::list<p2t::Triangle*> map = cdt.GetMap();
    std::vector<p2t::Triangle*> map = cdt.GetTriangles();

    K triPt = ktn(0,map.size());
    K triAdj = ktn(0,map.size());
    std::unordered_map<p2t::Triangle *, int> triNum;
    triNum[0] = ni;
    size_t i = 0;
    for (p2t::Triangle *tri : map) {
        K a = ktn(9, 2);
        K b = ktn(9, 2);
        K c = ktn(9, 2);
        p2t::Point *ptA = tri->GetPoint(0);
        p2t::Point *ptB = tri->GetPoint(1);
        p2t::Point *ptC = tri->GetPoint(2);
        kF(a)[0] = ptA->x;
        kF(a)[1] = ptA->y;
        kF(b)[0] = ptB->x;
        kF(b)[1] = ptB->y;
        kF(c)[0] = ptC->x;
        kF(c)[1] = ptC->y;
        K ktri = knk(3, a, b, c);
        kK(triPt)[i] = ktri;
        triNum[tri] = i;
        ++i;
    }
    i = 0;
    for (p2t::Triangle *tri : map) {
        p2t::Triangle *nbrA = tri->GetNeighbor(0);
        p2t::Triangle *nbrB = tri->GetNeighbor(1);
        p2t::Triangle *nbrC = tri->GetNeighbor(2);
        int nbrIdA = (triNum.count(nbrA) ? triNum[nbrA] : ni);
        int nbrIdB = (triNum.count(nbrB) ? triNum[nbrB] : ni);
        int nbrIdC = (triNum.count(nbrC) ? triNum[nbrC] : ni);
        K triAdjOne = ktn(6, 3);
        kI(triAdjOne)[0] = nbrIdA;
        kI(triAdjOne)[1] = nbrIdB;
        kI(triAdjOne)[2] = nbrIdC;
        kK(triAdj)[i] = triAdjOne;
        ++i;
    }
    for (p2t::Point *pp : polyV) delete pp;
    for (std::vector<p2t::Point *> &hv : holesV) {
        for (p2t::Point *pp : hv) {
            delete pp;
        }
    }

    K result = knk(2,triPt,triAdj);
    return result;
}

void floodfill(K map, int row, int col, int width, int height, int comp) {
    std::queue<std::pair<int, int>> queue;
    queue.push({row,col});
    while (!queue.empty()) {
        auto curr = queue.front();
        queue.pop();
        if (kG(kK(map)[curr.first])[curr.second] != 0) continue;
        kG(kK(map)[curr.first])[curr.second] = comp;
        if (curr.first>0) queue.push({curr.first-1,curr.second});
        if (curr.second>0) queue.push({curr.first,curr.second-1});
        if (curr.first<height-1) queue.push({curr.first+1,curr.second});
        if (curr.second<width-1) queue.push({curr.first,curr.second+1});
    }
}

K colorMap(K map) {
    if (map->t != 0) return kerror("map must be a general list");
    size_t width = 0;
    size_t height = map->n;
    for (size_t i=0; i<map->n; ++i) {
        if (kK(map)[i]->t != 4) return kerror("map must consist of byte lists");
        if (i == 0) width = kK(map)[0]->n;
        else if (kK(map)[0]->n != width) return kerror ("map must contain lists of equal length");
    }
    K result = ktn(0,height);
    for (size_t i=0; i<height; ++i) {
        K row = ktn(4, width);
        memcpy(kG(row), kG(kK(map)[i]), width);
        kK(result)[i] = row;
    }
    int compnum = 2;
    for (size_t i=0; i<height; ++i) {
        for (size_t j=0; j<width; ++j) {
            if (kG(kK(result)[i])[j] == 0) {
                floodfill(result, i, j, width, height, compnum);
                ++compnum;
            }
        }
    }
    return result;
}

inline int marchingSquareScore(int i, int j, int wp1, int hp1, K map, int comp) {
    int score = 0;
    if (j>0 && i<hp1-1) score += 1*(kG(kK(map)[i])[j-1] == comp);
    if (j<wp1-1 && i<hp1-1) score += 2*(kG(kK(map)[i])[j] == comp);
    if (j<wp1-1 && i>0) score += 4*(kG(kK(map)[i-1])[j] == comp);
    if (j>0 && i>0) score += 8*(kG(kK(map)[i-1])[j-1] == comp);
    return score;
}

double wallSize = 0.0;
double bridgeSize = 0.25;
const double gridOffsetX = -0.5;
const double gridOffsetY = -0.5;

inline void adjustPathXY(double &pathX, double &pathY, int score, int travelDir) {
    switch(score) {
        case 1:pathX -= wallSize; pathY += wallSize; break;
        case 2:pathX += wallSize; pathY += wallSize; break;
        case 4:pathX += wallSize; pathY -= wallSize; break;
        case 8:pathX -= wallSize; pathY -= wallSize; break;
        case 14:pathX += wallSize; pathY -= wallSize; break;
        case 13:pathX -= wallSize; pathY -= wallSize; break;
        case 11:pathX -= wallSize; pathY += wallSize; break;
        case 7:pathX += wallSize; pathY += wallSize; break;
        case 5:switch(travelDir) {
            case 4:pathX += wallSize; pathY -= wallSize; break;
            case 2:pathX -= wallSize; pathY += wallSize; break;
        }break;
        case 10:switch(travelDir) {
            case 3:pathX += wallSize; pathY += wallSize; break;
            case 1:pathX -= wallSize; pathY -= wallSize; break;
        }break;
    }
}

K getPathFrom(int i, int j, int wp1, int hp1, K map, int comp, bool *visited) {
    int score = marchingSquareScore(i,j,wp1,hp1,map,comp);
    if (score == 0 || score == 15) return 0;
    //std::cout << "getPathFrom i=" << i <<" j=" << j << " score=" << score <<std::endl;
    K result = ktn(0,0);
    int travelDir = 0;
    switch(score) {
        case 3:while(score == 3) {
            travelDir = 3;
            j-=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
            visited[i*wp1+j] = true;
        }
        case 6:while(score == 6) {
            travelDir = 4;
            i+=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
            visited[i*wp1+j] = true;
        }
        case 9:while(score == 9) {
            travelDir = 2;
            i-=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
            visited[i*wp1+j] = true;
        }
        case 12:while(score == 12) {
            travelDir = 1;
            j+=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
            visited[i*wp1+j] = true;
        }
    }
    int i0 = i;
    int j0 = j;
    double pathX = j+gridOffsetX;
    double pathY = i+gridOffsetY;
    switch(score) {
    case 4:case 12:case 13:travelDir = 1; break;
    case 8:case 9:case 11:travelDir = 2; break;
    case 1:case 3:case 7:travelDir = 3; break;
    case 2:case 6:case 14:travelDir = 4; break;
    case 5:switch(travelDir) {
        case 4:travelDir = 1; pathX+=bridgeSize; break;
        case 2:travelDir = 3; pathX-=bridgeSize; break;
    };break;
    case 10:switch(travelDir) {
        case 3:travelDir = 4; pathY+=bridgeSize; break;
        case 1:travelDir = 2; pathY-=bridgeSize; break;
    };break;
    }
    adjustPathXY(pathX,pathY,score,travelDir);
    int travelDir0 = travelDir;
    //std::cout << "i0=" << i0 <<" j0=" << j0 << " score=" << score << " travelDir0=" << travelDir0 << std::endl;
    do {
        //std::cout << "step: i=" << i << " j=" << j << " score=" << score << " travelDir=" << travelDir << std::endl;
        K pt = ktn(9,2);
        kF(pt)[0] = pathX;
        kF(pt)[1] = pathY;
        jk(&result, pt);
        switch(travelDir) {
        case 1:j+=1;break;
        case 2:i-=1;break;
        case 3:j-=1;break;
        case 4:i+=1;break;
        }
        visited[i*wp1+j] = true;
        score = marchingSquareScore(i, j, wp1, hp1, map, comp);
        switch(score) {
            case 3:while(score == 3) {
                //std::cout << "substep: i=" << i << " j=" << j << " travelDir=" << travelDir << std::endl;
                if (i0 == i && j0 == j && travelDir == travelDir0) return result;
                j-=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
                visited[i*wp1+j] = true;
            }
            case 6:while(score == 6) {
                //std::cout << "substep: i=" << i << " j=" << j << " travelDir=" << travelDir << std::endl;
                if (i0 == i && j0 == j && travelDir == travelDir0) return result;
                i+=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
                visited[i*wp1+j] = true;
            }
            case 9:while(score == 9) {
                //std::cout << "substep: i=" << i << " j=" << j << " travelDir=" << travelDir << std::endl;
                if (i0 == i && j0 == j && travelDir == travelDir0) return result;
                i-=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
                visited[i*wp1+j] = true;
            }
            case 12:while(score == 12) {
                //std::cout << "substep: i=" << i << " j=" << j << " travelDir=" << travelDir << std::endl;
                if (i0 == i && j0 == j && travelDir == travelDir0) return result;
                j+=1; score = marchingSquareScore(i, j, wp1, hp1, map, comp);
                visited[i*wp1+j] = true;
            }
        }
        pathX = j+gridOffsetX;
        pathY = i+gridOffsetY;
        adjustPathXY(pathX,pathY,score,travelDir);
        switch(score) {
            case 4:case 12:case 13:travelDir = 1; break;
            case 8:case 9:case 11:travelDir = 2; break;
            case 1:case 7:travelDir = 3; break;
            case 2:case 6:case 14:travelDir = 4; break;
            case 5:{
                switch(travelDir) {
                case 4:{ //switch cases to flip bridge
                    K pt = ktn(9,2);
                    kF(pt)[0] = pathX;
                    kF(pt)[1] = pathY-bridgeSize; //alter sign to flip bridge
                    jk(&result, pt);
                    travelDir = 1;
                    pathX += bridgeSize;
                    break;
                }
                case 2:{ //switch cases to flip bridge
                    K pt = ktn(9,2);
                    kF(pt)[0] = pathX;
                    kF(pt)[1] = pathY+bridgeSize; //alter sign to flip bridge
                    jk(&result, pt);
                    travelDir = 3;
                    pathX -= bridgeSize;
                    break;
                }
                }
                break;
            }
            case 10:{
                switch(travelDir) {
                case 3:{ //switch cases to flip bridge
                    K pt = ktn(9,2);
                    kF(pt)[0] = pathX+bridgeSize; //alter sign to flip bridge
                    kF(pt)[1] = pathY;
                    jk(&result, pt);
                    travelDir = 4;
                    pathY += bridgeSize;
                    break;
                }
                case 1:{ //switch cases to flip bridge
                    K pt = ktn(9,2);
                    kF(pt)[0] = pathX-bridgeSize; //alter sign to flip bridge
                    kF(pt)[1] = pathY;
                    jk(&result, pt);
                    travelDir = 2;
                    pathY -= bridgeSize;
                    break;
                }
                }
                break;
            }
            break;
        }
    } while (i0 != i || j0 != j || travelDir != travelDir0);
    return result;
}

K setWallSize(K size) {
    if (size->t != -9) return kerror("wall size must be float");
    wallSize = size->f;
    bridgeSize = 0.25-wallSize/2;
    return K(0);
}

K getContour(K map, K compid) {
    if (compid->t != -4)return kerror("compid must be a byte");
    if (map->t != 0) return kerror("map must be a general list");
    int comp = compid->g;
    size_t width = 0;
    size_t height = map->n;
    for (size_t i=0; i<map->n; ++i) {
        if (kK(map)[i]->t != 4) return kerror("map must consist of byte lists");
        if (i == 0) width = kK(map)[0]->n;
        else if (kK(map)[0]->n != width) return kerror ("map must contain lists of equal length");
    }
    K result = ktn(0,0);
    size_t wp1 = width+1;
    size_t hp1 = height+1;
    //K result = ktn(0,hp1);
    bool *visited = new bool[wp1*hp1];
    memset(visited, 0, wp1*hp1);
    for (size_t i=0; i<hp1; ++i) {
        //K resultRow = ktn(6,wp1);
        for (size_t j=0; j<wp1; ++j) {
            if (!visited[i*wp1+j]) {
                visited[i*wp1+j] = true;
                K path = getPathFrom(i,j,wp1,hp1,map,comp,visited);
                if (path != 0)
                    jk(&result,path);
                //kI(resultRow)[j] = score;
            }
        }
        //kK(result)[i] = resultRow;
    }
    delete[] visited;
    return result;
}

}
