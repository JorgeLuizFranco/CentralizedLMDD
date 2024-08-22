module DroneModel

using JuMP, Random, Gurobi

ENV["GRB_LICENSE_FILE"] = "/home/jorgerix//gurobi.lic"

# Function to set up and solve the MILP model
function solve_model(grid_rows, grid_columns, T, drones)
    R = keys(drones)
    
    cont = 10
    B = []
    E = []
    virtual_real_dict = Dict()
    real_virtual_dict = Dict()

    for (key, val) in drones
        real_virtual_dict[val["begin"]] = -1 .* (cont,cont)

        virtual_real_dict[-1 .* (cont,cont)] = val["begin"]

        push!(B,-1 .* (cont,cont))

        cont+=1

        real_virtual_dict[val["end"]] = -1 .* (cont,cont)
        
        virtual_real_dict[-1 .* (cont,cont)] = val["end"]
        
        push!(E,-1 .* (cont,cont))

        cont += 1
    end

    # Shared vertices S (shared space)
    S = vec([(i, j) for i in 1:grid_rows, j in 1:grid_columns])

    # Vertices of the final graph
    V = vcat(S, B, E)


    # Arrows indicating adjacent moves and loops (within the shared space S)
    A = [(v, w) for v in S for w in S if (v == w || (abs(v[1] - w[1]) + abs(v[2] - w[2]) == 1))]

    # Include the arrows related to the virtual vertices (v_begin, v_end)
    for (v_begin, v_end) in zip(B, E)
        v_begin_real = virtual_real_dict[v_begin]
        v_end_real = virtual_real_dict[v_end]
        push!(A, (v_begin, v_begin))         # loop: initial virtual vertex to itself
        push!(A, (v_begin, v_begin_real))    # initial virtual vertex to its enter to the shared space
        push!(A, (v_end_real, v_end))        # exit from the shared space to the final virtual vertex
        push!(A, (v_end, v_end))             # loop: final virtual vertex to itself
    end

    A= Set(A)

    # # Optimization model
    # model = Model(GLPK.Optimizer)

    model = Model(Gurobi.Optimizer)
    set_attribute(model, "TimeLimit", 1000)
    #set_attribute(model, "Presolve", 0)

    # Decision variables
    @variable(model, x[k=R, t=0:T, (i,j)=A], Bin)  # x[k,t,(i,j)] = 1 if drone k moves from vertice i to vertice j at time t

    # Objective: minimize the sum of movements
    @objective(model, Min, (sum(x[k,t,(i,j)] for k ∈ R, t ∈ 1:T, (i,j) ∈ A if j ∉ (E ∪ B)))  / (length(R)) )

    # Constraint - Initial movement
    for k in R
        b_k = B[k]
        @constraint(model, sum(x[k,t,(b_k,j)] for t ∈ 1:T, j ∈ S if (b_k,j) ∈ A) == 1)
    end

    # Constraints - Border condition
    for k in R, (i,j) in A
        b_k = B[k]
        if (i == b_k) && (j == b_k)
            @constraint(model, x[k,0,(b_k,b_k)] == 1)
        else
            @constraint(model, x[k,0,(i,j)] == 0)
        end
    end

    # Constraint - Flow conservation
    for j in V, k in R, t in 1:T
        @constraint(model, sum(x[k,t-1,(i,j)] for i in V if (i,j) ∈ A) == sum(x[k,t,(j,l)] 
            for l in V if (j,l) ∈ A))
    end

    # Constraint - Mutual exclusion of vertex occupation
    for j in V, t in 1:T
        @constraint(model, sum(x[k,t,(i,j)] for k in R, i in V if (i,j) ∈ A) <= 1)
    end

    # Constraint - Mission Accomplishment
    for k in R
        e_k = E[k]
        @constraint(model, sum(x[k,t,(i,e_k)] for t ∈ 1:T, i ∈ S if (i,e_k) ∈ A) == 1)
    end

    optimize!(model)

    #@assert is_solved_and_feasible(model)

    if !(is_solved_and_feasible(model))
        return model, x, -1
    end

    return model, x, objective_value(model)
end

# Function to generate random drone positions
function generate_random_drones(num_drones, grid_rows, grid_columns)
    drones = Dict()
    for i in 1:num_drones
        start = (rand(1:grid_rows), rand(1:grid_columns))
        finish = (rand(1:grid_rows), rand(1:grid_columns))
        
        # Ensure start and end positions are different
        while start == finish
            finish = (rand(1:grid_rows), rand(1:grid_columns))
        end
        
        drones[i] = Dict("begin" => start, "end" => finish)
    end
    return drones
end

end # module