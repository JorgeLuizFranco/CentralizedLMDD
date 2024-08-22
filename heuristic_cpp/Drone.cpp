// Drone.cpp

#include "Drone.h"

Drone::Drone(int id, const ask_pair& ask) : ask(ask), id(id) {
    // Your initialization logic here
    heuristic = std::hypot(ask.first.first - ask.second.first, ask.first.second - ask.second.second);
}