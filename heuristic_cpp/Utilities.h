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

#include "Drone.h"
#include <vector>
#include <map>
#include <iostream>

void read_drones(int k, std::vector<Drone>& drones);

void read_drones_experiment(int k, std::vector<Drone>& drones, std::istream& input);

bool valid_position(int x, int y, int n, int m);

void print_cost_dist_time(const std::vector<Drone>& drones);

void print_cost_dist_time_experiment(const std::vector<Drone>& drones, std::ostream& output);

void print_paths_array(const std::vector<Drone>& drones);

void print_paths_array_experiment(const std::vector<Drone>& drones, std::ostream& output);

void print_paths(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m);

void print_grid(const std::vector<std::vector<char>>& grid, std::map<std::pair<point_ii, int>, int>& scheduled, int flight_time);

void print_grid_experiment(const std::vector<std::vector<char>> &grid, std::map< std::pair<point_ii,int>, int>& scheduled, 
                                                                int flight_time, std::ostream& output);
                                                            
void print_paths_complete(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m);

void print_paths_complete_experiment(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m, std::ostream& output);

void print_normalized_per_drone_dist_experiment(const std::vector<Drone>& drones, std::ostream& output);


                

