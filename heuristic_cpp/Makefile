CXX := g++
CXXFLAGS := -Wall -std=c++17 -I.

# Name of the final executable
TARGET := drone_simulation

# Source files to compile
SRCS := main.cpp Drone.cpp Utilities.cpp PathFinding.cpp

# Object files corresponding to source files
OBJS := $(SRCS:.cpp=.o)

# Rule to link the final executable
$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJS)

# Rule to compile source files into object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean the built files
clean:
	rm -f $(TARGET) $(OBJS)

.PHONY: clean