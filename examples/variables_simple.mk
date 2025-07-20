CXX = g++
SOURCES = main.cpp utils.cpp
myapp: main.o utils.o
	g++ -o myapp main.o utils.o
main.o: main.cpp
	g++ -c main.cpp -o main.o
utils.o: utils.cpp
	g++ -c utils.cpp -o utils.o
