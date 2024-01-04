abstract type AbstractSamplingModel end

mutable struct EpsilonSamplingModel <: AbstractSamplingModel

    # data -
    α::Array{Float64,1}
    β::Array{Float64,1}
    K::Int64
    ϵ::Float64

    # constructor -
    EpsilonSamplingModel() = new();
end