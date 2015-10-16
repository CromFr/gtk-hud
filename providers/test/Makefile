all: main.cpp
	g++ -c -fPIC main.cpp -o main.o
	g++ -shared -Wl,-soname,test.so -o test.so  main.o
	# strip test.so