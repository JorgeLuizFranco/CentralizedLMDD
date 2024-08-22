// -*- lsst-c++ -*-

/*
 * [Copyright and Licensing Boilerplate]
 */

/**
 * @file PathFinding.h
 * @brief Contains utility functions for the drone simulation, such as path finding
 * @ingroup DroneSimulation
 * @author Jorge Luiz Franco
 * Contact: francojlf@ita.br
 */

#pragma once

#include "Drone.h"
#include <vector>
#include <map>

std::vector<point_ii> bfs_min_path(int n, int m, Drone &drone, std::map<std::pair<point_ii, int>, int>& scheduled);

void path_update(std::vector<point_ii>& path, int t, int &i, int &j, Drone& drone, std::map<std::pair<point_ii, int>, int>& scheduled, std::map<std::pair<point_ii, int>, point_ii>& parent);

std::vector<point_ii> retrieve_path(std::map<std::pair<point_ii, int>, point_ii>& parent, point_ii drone_end, Drone &drone, std::map<std::pair<point_ii, int>, int>& scheduled);