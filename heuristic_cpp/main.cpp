#include "PathFinding.h"
#include "Utilities.h"
#include <iostream>
#include <fstream>
#include <map>
#include <algorithm>

// solve function orchestrates the pathfinding and scheduling for drones.
void solve(int n, int m, std::vector<Drone>& drones,  std::ostream &output) {

    std::sort(drones.begin(), drones.end(), [](const Drone& a, const Drone& b) {
        return a.heuristic < b.heuristic;
    });

    std::map<std::pair<point_ii, int>, int> scheduled;
    for (auto& drone : drones) {
        drone.path = bfs_min_path(n, m, drone, scheduled);
        //drone.flight_time_end = scheduled[{drone.path.back(), drone.id}]; // Update flight end time
    }
    

    // print_cost_dist_time_experiment(drones, output);

    // output<<"\n\n";

    // print_paths_array_experiment(drones,output);
    
    // output<<"\n\n";
    
    // print_paths_complete_experiment(drones, scheduled, n, m, output);
    
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <input_file> <output_file>\n";
        return 1;
    }

    std::ifstream input(argv[1]);
    std::ofstream output(argv[2]);

    if (!input.is_open() || !output.is_open()) {
        std::cerr << "Error opening input or output file.\n";
        return 1;
    }

    int N, M, K;
    input >> N >> M >> K;

    std::vector<Drone> drones;
    read_drones_experiment(K, drones, input);

    solve(N, M, drones, output);

    print_normalized_per_drone_dist_experiment(drones, output);

    return 0;
}

