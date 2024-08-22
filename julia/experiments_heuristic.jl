using Pkg
using Plots
using JuMP
using Random
using Printf


include("model.jl")

include("utils.jl")

using .DroneModel



infeasible_files = ""


run_experiments_heuristic(6, 6, 99, 30)



println(infeasible_files)
