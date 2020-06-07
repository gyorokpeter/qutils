cls
g++ -o poly2tri2.dll -shared poly2tri_k.cpp shapes.o cdt.o sweep.o sweep_context.o advancing_front.o -I.. -ID:/Projects/github/poly2tri/poly2tri -L.. -lq
