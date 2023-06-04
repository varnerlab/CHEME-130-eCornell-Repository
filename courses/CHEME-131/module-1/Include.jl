# Setup local paths -
const _ROOT = pwd();
const _PATH_TO_DATA = joinpath(_ROOT, "data")
const _PATH_TO_SRC = joinpath(_ROOT, "src")


# load packages -
# download external packages
import Pkg; Pkg.activate("."); Pkg.instantiate();

# load packages into namespace
using DataFrames
using CSV
using Plots
using Colors
using Statistics
using Dates
using StatsPlots
using Distributions
using PrettyTables
using IJulia # not sure why this is required - is this a 1.9 thing?
using Optim

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Files.jl"))
include(joinpath(_PATH_TO_SRC, "Compute.jl"))
include(joinpath(_PATH_TO_SRC, "Calibrate.jl"))

# Setup color pallete -
colors = Dict{Int64,RGB}()
colors[1] = colorant"#EE7733";
colors[2] = colorant"#0077BB";
colors[3] = colorant"#33BBEE";
colors[4] = colorant"#EE3377";
colors[5] = colorant"#CC3311";
colors[6] = colorant"#009988";
colors[7] = colorant"#BBBBBB";