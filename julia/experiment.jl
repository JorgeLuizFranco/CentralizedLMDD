using Pkg
using Plots
using JuMP
using Random
using StatsPlots
using Printf
using CSV
using DataFrames

include("model.jl")

include("utils.jl")

using .DroneModel


gr()

infeasible_files = ""

# function to run comparison exact vs heuristic model experiments 
function run_experiments(grid_rows, grid_columns, max_drones, num_trials; stepx=1)
    num_drones_list = 1:stepx:max_drones
    julia_times = Dict{Int, Vector{Float64}}()
    julia_obj_values = Dict{Int, Vector{Float64}}()
    cpp_times = Dict{Int, Vector{Float64}}()
    cpp_obj_values = Dict{Int, Vector{Float64}}()

    for num_drones in num_drones_list
        julia_times[num_drones] = []
        julia_obj_values[num_drones] = []
        cpp_times[num_drones] = []
        cpp_obj_values[num_drones] = []
        
        for trial in 1:num_trials
            drones = DroneModel.generate_random_drones(num_drones, grid_rows, grid_columns)
            
            # C++ heuristic
            write_drones_to_file(drones, "../heuristic_cpp/inputs/input$(10*num_drones)$(trial).txt", grid_rows, grid_columns)
            heuristic_start_time = time()
            experiment_type = "comparison_plot"  # or "norm_dist_exp", depending on the experiment type
            run(`../heuristic_cpp/drone_simulation ../heuristic_cpp/inputs/input$(10*num_drones)$(trial).txt ../heuristic_cpp/outputs/output$(10*num_drones)$(trial).txt $(experiment_type)`)
            heuristic_end_time = time()
            average_distance, max_T = read_cpp_results("../heuristic_cpp/outputs/output$(10*num_drones)$(trial).txt")
            
            println(average_distance, "   ", max_T, "\n")

            # Julia model
            start_time = time()
            model, x, obj_value = DroneModel.solve_model(grid_rows, grid_columns, max_T+2, drones)
            end_time = time()

            if obj_value == -1
                global infeasible_files *= "\n\n" * "/heuristic_cpp/inputs/input$(10*num_drones)$(trial).txt" * "\n" * repr(drones) * "\n\n"
            else
                push!(cpp_times[num_drones], heuristic_end_time - heuristic_start_time)
                push!(cpp_obj_values[num_drones], average_distance)
                
                push!(julia_times[num_drones], end_time - start_time)
                push!(julia_obj_values[num_drones], obj_value)
            end
        end
    end

    return num_drones_list, julia_times, julia_obj_values, cpp_times, cpp_obj_values
end




# Example parameters
grid_rows = 6
grid_columns = 6
max_drones = 66
num_trials = 20

# Run unified experiments
num_drones_list, julia_times, julia_obj_values, cpp_times, cpp_obj_values = run_experiments(
    grid_rows, grid_columns, max_drones, num_trials, stepx=7)

# Plot individual boxplots
plot_individual_boxplots(num_drones_list, julia_times, julia_obj_values, cpp_times, cpp_obj_values)
