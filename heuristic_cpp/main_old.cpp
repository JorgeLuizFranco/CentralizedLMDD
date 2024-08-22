#include "PathFinding.h"
#include "Utilities.h"
#include <iostream>
#include <map>

//solve function orchestrates the pathfinding and scheduling for drones.
void solve(int n, int m, std::vector<Drone>& drones) {
    std::map<std::pair<point_ii, int>, int> scheduled;
    for (auto& drone : drones) {
        drone.path = bfs_min_path(n, m, drone, scheduled);
    }
}

int main() {
    int N, M, K;

    std::vector<Drone> drones;

    std::cin >> N >> M >> K;
    
    read_drones(K, drones);

    // The solve function is called here after all drones are initialized.
    solve(N, M, drones);

    print_cost_dist_time(drones);
    print_paths_array(drones);

    return 0;
}