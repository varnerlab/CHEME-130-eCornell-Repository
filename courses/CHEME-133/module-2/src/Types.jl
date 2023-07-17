abstract type AbstractAssetModel end
abstract type AbstractContractModel <: AbstractAssetModel end
abstract type AbstractPriceTreeModel <: AbstractAssetModel end

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

mutable struct MyEquityModel <: AbstractAssetModel

    # data -
    ticker::String
    purchase_price::Float64
    current_price::Float64
    direction::Int64
    number_of_shares::Int64

    # constructor -
    EquityModel() = new()
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

mutable struct MyCRRLatticeNodeModel

    # data -
    price::Float64
    probability::Float64
    intrinsic::Float64
    extrinsic::Float64

    # constructor -
    MyCRRLatticeNodeModel() = new();
end

mutable struct MyAdjacencyBasedCRREquityPriceTree <: AbstractPriceTreeModel

    # data -
    data::Dict{Int, MyCRRLatticeNodeModel}
    connectivity::Dict{Int64, Array{Int64,1}}
    levels::Dict{Int64,Array{Int64,1}}
    u::Float64
    p::Float64
    ΔT::Float64
    μ::Float64

    # constructor 
    MyAdjacencyBasedCRREquityPriceTree() = new()
end