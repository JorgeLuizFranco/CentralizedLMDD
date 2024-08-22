using CSV
using DataFrames

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


# Function to plot boxplots
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

    # Convert groups to strings with leading zeros for proper labeling
    julia_time_groups_str = [ @sprintf("%02i", x) for x in julia_time_groups ]
    julia_obj_groups_str = [ @sprintf("%02i", x) for x in julia_obj_groups ]
    cpp_time_groups_str = [ @sprintf("%02i", x) for x in cpp_time_groups ]
    cpp_obj_groups_str = [ @sprintf("%02i", x) for x in cpp_obj_groups ]

    # Plot boxplot for Julia model running time
    p1 = boxplot(julia_time_groups_str, julia_time_data, group=julia_time_labels,
                 xlabel="Number of Drones", ylabel="Time (s)",
                 title="Exact Model: Running Time vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:blue)
    display(p1)
    savefig(p1, "julia_time_boxplot_vs_drones.png")

    # Plot boxplot for Julia model objective value
    p2 = boxplot(julia_obj_groups_str, julia_obj_data, group=julia_obj_labels,
                 xlabel="Number of Drones", ylabel="Objective Value",
                 title="Exact Model: Objective Value vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:blue)
    display(p2)
    savefig(p2, "julia_obj_boxplot_vs_drones.png")

    # Plot boxplot for C++ heuristic running time
    p3 = boxplot(cpp_time_groups_str, cpp_time_data, group=cpp_time_labels,
                 xlabel="Number of Drones", ylabel="Time (s)",
                 title="Heuristic: Running Time vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:red)
    display(p3)
    savefig(p3, "cpp_time_boxplot_vs_drones.png")

    # Plot boxplot for C++ heuristic objective value
    p4 = boxplot(cpp_obj_groups_str, cpp_obj_data, group=cpp_obj_labels,
                 xlabel="Number of Drones", ylabel="Objective Value",
                 title="Heuristic: Objective Value vs Number of Drones", fillalpha=0.75, linewidth=1, legend=false,
                 color=:red)
    display(p4)
    savefig(p4, "cpp_obj_boxplot_vs_drones.png")
end




# Function to generate random drones and write to an input file
function generate_drones_input(num_drones, grid_rows, grid_columns)
    drones = DroneModel.generate_random_drones(num_drones, grid_rows, grid_columns)
    input_file = "input_drones.txt"
    write_drones_to_file(drones, input_file, grid_rows, grid_columns)
    return input_file
end

# Function to run the C++ heuristic
function run_cpp_heuristic(input_file, output_file)
    run(`../heuristic_cpp/drone_simulation $input_file $output_file`)
end

# Function to read a single result from the C++ heuristic output
function read_single_cpp_result(output_file)
    open(output_file, "r") do io
        for line in eachline(io)
            parts = split(line)
            if length(parts) == 3
                num_drones = parse(Int, parts[1])
                normalized_distance = parse(Float64, parts[2])
                routing_time = parse(Float64, parts[3])
                return num_drones, normalized_distance, routing_time
            else
                println("Skipping malformed line: $line")
            end
        end
    end
end

# Function to plot normalized distances using StatsPlots
function plot_normalized_distances(num_drones_list, normalized_distances)
    # Prepare the data for boxplots
    normalized_data = []
    normalized_groups = []

    for n in num_drones_list
        dists = normalized_distances[n]
        append!(normalized_data, dists)
        append!(normalized_groups, fill(n, length(dists)))
    end

    # Save the data to CSV
    df_normalized = DataFrame(Number_of_Drones=normalized_groups, Normalized_Distance=normalized_data)
    CSV.write("normalized_distances.csv", df_normalized)

    # Convert groups to strings with leading zeros for proper labeling
    normalized_groups_str = [ @sprintf("%02i", x) for x in normalized_groups ]

    # Plot boxplot for normalized distances
    p = boxplot(normalized_groups_str, normalized_data,
                xlabel="Number of Drones", ylabel="Normalized Distance",
                fillalpha=0.75, linewidth=2, legend=false,
                color=:orange, guidefont=font(10,"Times"), tickfont=font(10,"Times"))

    display(p)
    savefig(p, "cpp_normalized_distance_boxplot_vs_drones.pdf")
end

function plot_routing_times(num_drones_list, routing_times)
    # Prepare the data for boxplots
    routing_data = []
    routing_groups = []

    for n in num_drones_list
        times = routing_times[n]
        append!(routing_data, times)
        append!(routing_groups, fill(n, length(times)))
    end

    # Save the data to CSV
    df_routing = DataFrame(Number_of_Drones=routing_groups, Routing_Time=routing_data)
    CSV.write("routing_times.csv", df_routing)

    # Convert groups to strings with leading zeros for proper labeling
    routing_groups_str = [ @sprintf("%02i", x) for x in routing_groups ]

    # Plot boxplot for routing times
    p = boxplot(routing_groups_str, routing_data,
                xlabel="Number of Drones", ylabel="Routing Time (s)",
                fillalpha=0.75, linewidth=2, legend=false,
                color=:orange, guidefont=font(10,"Times"), tickfont=font(10,"Times"))

    display(p)
    savefig(p, "cpp_routing_time_boxplot_vs_drones.pdf")
end

# Main function to run the experiments
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



# DEPRECATED
# Function to run experiments and collect results
function run_experiments_deprecated(grid_rows, grid_columns, max_drones, T)
    num_drones_list = 1:max_drones
    times = []
    obj_values = []

    for num_drones in num_drones_list
        drones = DroneModel.generate_random_drones(num_drones, grid_rows, grid_columns)
        start_time = time()
        model, x, obj_value = DroneModel.solve_model(grid_rows, grid_columns, T, drones)
        end_time = time()
        push!(times, end_time - start_time)
        push!(obj_values, obj_value)
    end

    return num_drones_list, times, obj_values
end

# Function to plot results
function plot_results(num_drones_list, times, obj_values)
    # Plot time taken for different number of drones
    plot(num_drones_list, times, xlabel="Number of Drones", ylabel="Time (s)", label="Time to Solve", lw=2, title="Time vs Number of Drones")
    savefig("time_vs_drones.png")
    display(plot)

    # Plot objective value for different number of drones
    plot(num_drones_list, obj_values, xlabel="Number of Drones", ylabel="Objective Value", label="Objective Value", lw=2, title="Objective Value vs Number of Drones")
    savefig("obj_value_vs_drones.png")
    display(plot)
end