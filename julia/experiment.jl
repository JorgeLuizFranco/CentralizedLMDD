using Pkg
using Plots
using JuMP
using Random
using StatsPlots
using Printf
using CSV
using DataFrames

include("model.jl")
using .DroneModel

# Ensure the GR backend is used for headless plotting
ENV["GKSwstype"] = "100"  # Use "100" for PNG output
gr()

infeasible_files = ""

# Function to write drones to a file for C++ heuristic
function write_drones_to_file(drones, filename, grid_rows, grid_columns)
    open(filename, "w") do io
        println(io, "$grid_rows $grid_columns $(length(drones))")
        for (id, drone) in drones
            println(io, "$(drone["begin"][1] -1 ) $(drone["begin"][2] -1) $(drone["end"][1] -1 ) $(drone["end"][2] -1)")
        end
    end
end

# Function to read results from C++ heuristic
function read_cpp_results(filename)
    average_distance = -1.0
    max_time = -1
    open(filename, "r") do io
        for line in eachline(io)
            parts = split(line)
            if length(parts) == 2
                average_distance = parse(Float64, parts[1])
                max_time = parse(Int, parts[2])
            end
            return average_distance, max_time # since the other lines have their paths
        end
    end
    return average_distance, max_time
end

# Unified function to run experiments for statistical analysis with both Julia and C++ models
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
            run(`../heuristic_cpp/drone_simulation ../heuristic_cpp/inputs/input$(10*num_drones)$(trial).txt ../heuristic_cpp/outputs/output$(10*num_drones)$(trial).txt`)
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

# Function to save boxplot data to CSV
function save_boxplot_data(filename, groups, labels, data)
    df = DataFrame(Group = groups, Label = labels, Data = data)
    CSV.write(filename, df)
end

# Function to plot boxplots and save data to CSV
function plot_individual_boxplots(num_drones_list, julia_times, julia_obj_values, cpp_times, cpp_obj_values)
    # Prepare the data for boxplots
    julia_time_data = []
    julia_time_labels = []
    julia_time_groups = []

    julia_obj_data = []
    julia_obj_labels = []
    julia_obj_groups = []

    cpp_time_data = []
    cpp_time_labels = []
    cpp_time_groups = []

    cpp_obj_data = []
    cpp_obj_labels = []
    cpp_obj_groups = []

    for n in num_drones_list
        append!(julia_time_data, julia_times[n])
        append!(julia_time_labels, fill("Julia Model", length(julia_times[n])))
        append!(julia_time_groups, fill(n, length(julia_times[n])))

        append!(julia_obj_data, julia_obj_values[n])
        append!(julia_obj_labels, fill("Julia Model", length(julia_obj_values[n])))
        append!(julia_obj_groups, fill(n, length(julia_obj_values[n])))

        append!(cpp_time_data, cpp_times[n])
        append!(cpp_time_labels, fill("C++ Heuristic", length(cpp_times[n])))
        append!(cpp_time_groups, fill(n, length(cpp_times[n])))

        append!(cpp_obj_data, cpp_obj_values[n])
        append!(cpp_obj_labels, fill("C++ Heuristic", length(cpp_obj_values[n])))
        append!(cpp_obj_groups, fill(n, length(cpp_obj_values[n])))
    end

    # Save the data to CSV files
    save_boxplot_data("julia_time_data.csv", julia_time_groups, julia_time_labels, julia_time_data)
    save_boxplot_data("julia_obj_data.csv", julia_obj_groups, julia_obj_labels, julia_obj_data)
    save_boxplot_data("cpp_time_data.csv", cpp_time_groups, cpp_time_labels, cpp_time_data)
    save_boxplot_data("cpp_obj_data.csv", cpp_obj_groups, cpp_obj_labels, cpp_obj_data)

    # Convert groups to strings with leading zeros for proper labeling
    julia_time_groups_str = [ @sprintf("%02i", x) for x in julia_time_groups ]
    julia_obj_groups_str = [ @sprintf("%02i", x) for x in julia_obj_groups ]
    cpp_time_groups_str = [ @sprintf("%02i", x) for x in cpp_time_groups ]
    cpp_obj_groups_str = [ @sprintf("%02i", x) for x in cpp_obj_groups ]

    font = "Times"

    # Plot boxplot for Julia model running time
    p1 = boxplot(julia_time_groups_str, julia_time_data, group=julia_time_labels,
                 xlabel="Number of Drones", ylabel="Time (s)",
                 title="Exact Model: Running Time vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:blue, guidefont=font, tickfont=font, titlefont=font)
    display(p1)
    savefig(p1, "julia_time_boxplot_vs_drones.png")

    # Plot boxplot for Julia model objective value
    p2 = boxplot(julia_obj_groups_str, julia_obj_data, group=julia_obj_labels,
                 xlabel="Number of Drones", ylabel="Objective Value",
                 title="Exact Model: Objective Value vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:blue, guidefont=font, tickfont=font, titlefont=font)
    display(p2)
    savefig(p2, "julia_obj_boxplot_vs_drones.png")

    # Plot boxplot for C++ heuristic running time
    p3 = boxplot(cpp_time_groups_str, cpp_time_data, group=cpp_time_labels,
                 xlabel="Number of Drones", ylabel="Time (s)",
                 title="Heuristic: Running Time vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:red, guidefont=font, tickfont=font, titlefont=font)
    display(p3)
    savefig(p3, "cpp_time_boxplot_vs_drones.png")

    # Plot boxplot for C++ heuristic objective value
    p4 = boxplot(cpp_obj_groups_str, cpp_obj_data, group=cpp_obj_labels,
                 xlabel="Number of Drones", ylabel="Objective Value",
                 title="Heuristic: Objective Value vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:red, guidefont=font, tickfont=font, titlefont=font)
    display(p4)
    savefig(p4, "cpp_obj_boxplot_vs_drones.png")
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
println(infeasible_files)
plot_individual_boxplots(num_drones_list, julia_times, julia_obj_values, cpp_times, cpp_obj_values)
println(infeasible_files)