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
using IJulia # not sure why this is required - is this a 1.9 thing?

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Files.jl"))