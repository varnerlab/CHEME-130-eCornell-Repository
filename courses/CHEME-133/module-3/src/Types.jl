abstract type AbstractAssetModel end
abstract type AbstractContractModel <: AbstractAssetModel end

mutable struct MyEuropeanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Int64
    DTE::Float64
    IV::Float64
    premium::Union{Nothing, Float64}

    # constructor -
    MyEuropeanCallContractModel() = new()
end

mutable struct MyEuropeanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Int64
    DTE::Float64
    IV::Float64
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}

    # constructor -
    MyEuropeanPutContractModel() = new()
end

mutable struct MyAmericanCallContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Int64
    DTE::Float64
    IV::Float64
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}

    # constructor -
    MyAmericanCallContractModel() = new()
end

mutable struct MyAmericanPutContractModel <: AbstractContractModel

    # data -
    K::Float64
    sense::Int64
    DTE::Float64
    IV::Float64
    premium::Union{Nothing, Float64}
    ticker::Union{Nothing,String}

    # constructor -
    MyAmericanPutContractModel() = new()
end

"""
    mutable struct MyGeometricBrownianMotionModel <: AbstractSecurityModel
"""
mutable struct MyGeometricBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Float64
    σ::Float64

    # constructor -
    MyGeometricBrownianMotionEquityModel() = new()
end