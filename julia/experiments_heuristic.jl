using Pkg
using Plots
using JuMP
using Random
using Printf


include("model.jl")

include("utils.jl")

using .DroneModel

function run_experiments_heuristic(grid_rows, grid_columns, max_drones, num_trials; stepx=1)
    num_drones_list = Int[]
    normalized_distances = Dict{Int, Vector{Float64}}()
    routing_times = Dict{Int, Vector{Float64}}()
    output_file = "output_normalized_drones.txt"

    # Ensure the output file is empty before starting
    open(output_file, "w") do io
        write(io, "")
    end

    for num_drones in 1:stepx:max_drones
        for trial in 1:num_trials
            input_file = generate_drones_input(num_drones, grid_rows, grid_columns)
            run_cpp_heuristic(input_file, output_file)
            
            nd, normalized_distance, routing_time = read_single_cpp_result(output_file)
            
            if !haskey(normalized_distances, nd)
                normalized_distances[nd] = Float64[]
                routing_times[nd] = Float64[]
                push!(num_drones_list, nd)
            end
            push!(normalized_distances[nd], normalized_distance)
            push!(routing_times[nd], routing_time)            
        end
    end

    num_drones_list = sort(num_drones_list)
    #plot_normalized_distances(num_drones_list, normalized_distances)
    #plot_routing_times(num_drones_list, routing_times)
end


run_experiments_heuristic(6, 6, 99, 30)
