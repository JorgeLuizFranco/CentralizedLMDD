#include "Utilities.h"
#include <sstream>


void read_drones_experiment(int k, std::vector<Drone>& drones, std::istream& input) {
    for (int i = 0; i < k; i++) {
        int i_begin, j_begin, i_end, j_end;
        input >> i_begin >> j_begin >> i_end >> j_end;
        ask_pair ask = {{i_begin, j_begin}, {i_end, j_end}};
        drones.emplace_back(i, ask);
    }
}


void read_drones(int k,std::vector<Drone>& drones) {
    for (int i = 0; i < k; i++) {
        int i_begin, j_begin, i_end, j_end;
        std::cin >> i_begin >> j_begin >> i_end >> j_end;
        ask_pair ask = {{i_begin, j_begin}, {i_end, j_end}};
        drones.emplace_back(i, ask);
    }
}

bool valid_position(int x, int y, int n, int m) {
    return (x >= 0 && x < n) && (y >= 0 && y < m);
}

void print_cost_dist_time(const std::vector<Drone>& drones) {
    int total_time = 0;
    int total_distance = 0;
    for(const auto& drone : drones){
        int drone_time = drone.flight_time_end - drone.flight_time_begin;
        int drone_distance = static_cast<int>(drone.path.size());

        total_time += drone_time;
        total_distance += drone_distance;

        std::cout << "Drone " << drone.id << ":\n"
                  << "  Time: " << drone_time << "\n"
                  << "  Distance: " << drone_distance << "\n";
    }

    double average_time = static_cast<double>(total_time) / drones.size();
    double average_distance = static_cast<double>(total_distance) / drones.size();
    
    std::cout << "Average Time: " << average_time << "\n"
              << "Average Distance: " << average_distance << "\n"
              << "Mean: " << (average_time + average_distance) / 2 << "\n";
}

int find_max_time(const std::vector<Drone>& drones){
	int max_time=-1;

	for(auto drone: drones){
		max_time=std::max(max_time,drone.flight_time_end);
	}

	return max_time;
}


void print_cost_dist_time_experiment(const std::vector<Drone>& drones, std::ostream& output) {
    int total_distance = 0;
    for(const auto& drone : drones){
        
        int drone_distance = static_cast<int>(drone.path.size());

        total_distance += drone_distance;
    }

    double average_distance = static_cast<double>(total_distance) / drones.size();
    
    output <<  average_distance << ' '<< find_max_time(drones) << '\n';
    
}

void print_paths_array(const std::vector<Drone>& drones) {
    for(const auto& drone : drones){
        std::cout << "Drone " << drone.id << " path: [";
        for (const auto& pos : drone.path) {
            std::cout << "(" << pos.first << ", " << pos.second << "), ";
        }
        std::cout << "]" << std::endl;
    }
}

void print_paths_array_experiment(const std::vector<Drone>& drones, std::ostream& output) {
    output<<'\n';
    for(const auto& drone : drones){
        output << "Drone " << drone.id << " path: [";
        for (const auto& pos : drone.path) {
            output << "(" << pos.first << ", " << pos.second << "), ";
        }
        output << "]" << std::endl;
    }
}


void print_grid(const std::vector<std::vector<char>>& grid, std::map<std::pair<point_ii, int>, int>& scheduled, int flight_time){
    for (int i = 0; i < (int)grid.size(); ++i) {
        for (int j = 0; j < (int)grid[0].size(); ++j) {
            char cell = grid[i][j];

            // Check if the cell is scheduled
            std::pair<point_ii, int> pos_time = {point_ii(i, j), flight_time};

            if (cell == '#' && scheduled.find(pos_time) != scheduled.end()) {
                int drone_scheduled = scheduled[pos_time];
                std::cout << 'S' << drone_scheduled << ' ';
            } else {
                std::cout << cell << cell << ' ';
            }
        }
        std::cout << '\n';
    }
    std::cout << '\n';
}

void print_paths(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m){
    for (const Drone& drone : drones) {
        std::vector<std::vector<char>> grid(n, std::vector<char>(m, '#'));
        printf("Drone %d: \n\n", drone.id);
        int flight_time = drone.flight_time_begin;

        for (const point_ii& pos : drone.path) {
            auto [pos_i, pos_j] = pos;
            grid[pos_i][pos_j] = static_cast<char>('0' + drone.id);

            // If you wish to print each step
            //print_grid(grid, scheduled, flight_time);

            grid[pos_i][pos_j] = '#';
        }
        // If you wish to print after completing each drone's path
         print_grid(grid, scheduled, flight_time);
    }
}


void print_paths_complete(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m){

    int t_max= find_max_time(drones);

    for(int t=0 ; t<= t_max ; t++){

        std::vector<std::vector<char>> grid(n, std::vector<char>(m, '#'));

        for (const auto& entry : scheduled) {
            const auto& pos_time = entry.first;
            int drone_id = entry.second;
            if (pos_time.second == t) {
                const auto& pos = pos_time.first;
                int pos_i = pos.first;
                int pos_j = pos.second;
                grid[pos_i][pos_j] = static_cast<char>('0' + drone_id);
            }
        }

        print_grid(grid, scheduled, t);
    }
}

void print_grid_experiment(const std::vector<std::vector<std::string>>& grid, std::map<std::pair<point_ii, int>, int>& scheduled, int flight_time, std::ostream& output) {
    for (int i = 0; i < (int)grid.size(); ++i) {
        for (int j = 0; j < (int)grid[0].size(); ++j) {
            std::string cell = grid[i][j];

            // Check if the cell is scheduled
            // std::pair<point_ii, int> pos_time = {point_ii(i, j), flight_time};

            // if (cell == "##" && scheduled.find(pos_time) != scheduled.end()) {
            //     output<<"\n\n\n\nCARAMBAAAAAAAAAAAAA\n\n\n" ;
            //     int drone_scheduled = scheduled[pos_time];
            //     output << 'S' << std::setw(2) << std::setfill('0') << drone_scheduled << ' ';
            // } else {
            //     output << std::setw(2) << std::setfill('0') << cell << ' ';
            // }
            output<< cell<< ' ';
        }
        output << '\n';
    }
    output << '\n';
}

void print_paths_complete_experiment(const std::vector<Drone>& drones, std::map<std::pair<point_ii, int>, int>& scheduled, int n, int m, std::ostream& output) {
    int t_max = find_max_time(drones);

    output << '\n';

    for (int t = 0; t <= t_max; ++t) {
        std::vector<std::vector<std::string>> grid(n, std::vector<std::string>(m, "##"));

        output << "Time : " << t << "\n\n";

        for (const auto& entry : scheduled) {
            const auto& pos_time = entry.first;
            int drone_id = entry.second;
            if (pos_time.second == t) {
                const auto& pos = pos_time.first;
                int pos_i = pos.first;
                int pos_j = pos.second;
                std::ostringstream id_str;
                if (drone_id < 10) {
                    id_str << '0' << drone_id;
                } else {       
                    id_str << drone_id;
                }
                grid[pos_i][pos_j] = id_str.str();
            }
        }

        print_grid_experiment(grid, scheduled, t, output);

        output << "\n\n";
    }
}


inline double calculate_manhattan_distance(const ask_pair& ask) {
    return std::abs(ask.first.first - ask.second.first) + std::abs(ask.first.second - ask.second.second);
}

void print_normalized_per_drone_dist_experiment(const std::vector<Drone>& drones, std::ostream& output) {
    double total_normalized_distance = 0.0;
    for(const auto& drone : drones){
        double drone_distance = static_cast<double>(drone.path.size());
        double manhattan_distance = calculate_manhattan_distance(drone.ask);

        if (manhattan_distance != 0) {
            total_normalized_distance += drone_distance / manhattan_distance;
        }
    }

    output << drones.size()<< ' '<< total_normalized_distance << ' '<< find_max_time(drones) << '\n';
}

