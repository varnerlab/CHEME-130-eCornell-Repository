# setup paths -
const _ROOT = pwd()
const _PATH_TO_SRC = joinpath(_ROOT, "src");
const _PATH_TO_DATA = joinpath(_ROOT, "data");

# load packages -
import Pkg; Pkg.activate("."); Pkg.instantiate();
using Distributions
using LinearAlgebra
using Dates
using DataFrames
using CSV
using PrettyTables
using Statistics

# load my codes -
include(joinpath(_PATH_TO_SRC, "Types.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Compute.jl"))
include(joinpath(_PATH_TO_SRC, "Files.jl"))