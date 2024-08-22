// -*- lsst-c++ -*-

/*
 * [Copyright and Licensing Boilerplate]
 */

/**
 * @file Utilities.h
 * @brief Contains utility functions for the drone simulation, such as input handling and output formatting.
 * @ingroup DroneSimulation
 * @author Jorge Luiz Franco
 * Contact: francojlf@ita.br
 */

#pragma once

#include <vector>
#include <utility>
#include <string>
#include <cmath>

using point_ii = std::pair<int, int>;
using ask_pair = std::pair<point_ii, point_ii>;

class Drone {
public:
    int flight_time_begin = 0;
    int flight_time_end;
    std::vector<point_ii> path;
    ask_pair ask;  
    int id;
    double heuristic;

    Drone(int id, const ask_pair& ask);
};