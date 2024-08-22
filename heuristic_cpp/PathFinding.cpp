#include "PathFinding.h"
#include "Drone.h"
#include "Utilities.h"
#include <algorithm>
#include <queue>
#include <map>
#include <vector>
#include <utility>
#include <iostream>

const std::vector<point_ii> directions = {{0, 1}, {0, -1}, {1, 0}, {-1, 0}};

std::vector<point_ii> bfs_min_path(int n, int m, Drone &drone, std::map<std::pair<point_ii, int>, int>& scheduled) {
    std::queue<std::pair<point_ii, int>> bfs_queue;
    auto [drone_begin, drone_end] = drone.ask;

    bool path_found = false;

    drone.flight_time_begin = -1; // just for the first sum be 0

    while (!path_found) {
        drone.flight_time_begin++;

        std::map<std::pair<point_ii, int>, point_ii> parent;
        std::map<std::pair<point_ii, int>, bool> visited;

        //printf("\n\n HEY id: %d , time: %d\n\n", drone.id, drone.flight_time_begin);

        auto pos_time_begin = std::make_pair(drone_begin, drone.flight_time_begin);

        if (scheduled.find(pos_time_begin) != scheduled.end()) {
            continue;
        }

        bfs_queue.push({drone_begin, drone.flight_time_begin});
        visited[pos_time_begin] = true;

        while (!bfs_queue.empty()) {
            auto [position, flight_time] = bfs_queue.front();
            bfs_queue.pop();

            auto [pos_i, pos_j] = position;

            //printf("id: %d , pos: [%d,%d] , time: %d\n\n", drone.id, pos_i, pos_j, flight_time);

            if (drone_end == point_ii(pos_i, pos_j)) {
                drone.flight_time_end = flight_time;
                path_found = true; // Mark path as found
                return retrieve_path(parent, drone_end, drone, scheduled);
            }

            if (scheduled.find(std::make_pair(position, flight_time)) != scheduled.end()) {
                continue;
            }

            for (auto [d_i, d_j] : directions) {
                bool no_schedule = true;

                int next_pos_i = pos_i + d_i;
                int next_pos_j = pos_j + d_j;
                std::pair<point_ii, int> next_pos_time = {{next_pos_i, next_pos_j}, flight_time + 1};

                if (valid_position(next_pos_i, next_pos_j, n, m) && !visited[next_pos_time]) {
                    if (scheduled.find(next_pos_time) != scheduled.end()) {
                        if (no_schedule) {
                            no_schedule = false;
                            bfs_queue.push({position, flight_time + 1});
                        }
                        continue;
                    }
                    visited[next_pos_time] = true;
                    parent[next_pos_time] = {pos_i, pos_j};
                    bfs_queue.push(next_pos_time);
                }
            }
        }
    }

    return {};
}

void path_update(std::vector<point_ii>& path, int t, int &i, int &j, Drone& drone, std::map<std::pair<point_ii, int>, int>& scheduled, std::map<std::pair<point_ii, int>, point_ii>& parent) {
    path.push_back({i, j});
    auto pos_time = std::make_pair(point_ii(i, j), t);
    scheduled[pos_time] = drone.id; // Schedule the drone for this position and time
    if (parent.find(pos_time) != parent.end()) {
        std::tie(i, j) = parent[pos_time]; // Update to next position based on the traced path
    }
}

std::vector<point_ii> retrieve_path(std::map<std::pair<point_ii, int>, point_ii>& parent, point_ii drone_end, Drone &drone, std::map<std::pair<point_ii, int>, int>& scheduled) {
    std::vector<point_ii> path;
    auto [i, j] = drone_end;
    int t = drone.flight_time_end;

    // Trace the path backwards from the end position to the start
    while (t > drone.flight_time_begin || parent.find({{i, j}, t}) != parent.end()) {
        path_update(path, t, i, j, drone, scheduled, parent);
        t--;
    }
    path_update(path, t, i, j, drone, scheduled, parent);
    std::reverse(path.begin(), path.end()); // Reverse the path to the correct start-end order

    return path;
}
