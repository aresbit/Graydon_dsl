# Variables and dependencies example
CXX = g++
CXXFLAGS = -std=c++17 -Wall

SOURCES = main.cpp utils.cpp parser.cpp
OBJECTS = $(SOURCES:.cpp=.o)
EXECUTABLE = myapp

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CXX) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(EXECUTABLE)