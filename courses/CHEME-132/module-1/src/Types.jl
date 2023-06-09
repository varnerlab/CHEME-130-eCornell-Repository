abstract type AbstractAssetModel end
abstract type AbstractEquityPriceTreeModel <: AbstractAssetModel end
abstract type AbstractDerivativeContractModel <: AbstractAssetModel end


mutable struct MyBiomialLatticeEquityNodeModel

    # data -
    price::Float64
    probability::Float64

    # constructor -
    MyBiomialLatticeEquityNodeModel() = new();
end

"""
MyBinomialEquityPriceTree
"""
mutable struct MyBinomialEquityPriceTree <: AbstractEquityPriceTreeModel

    # data -
    connectivity::Union{Nothing, Dict{Int64, Array{Int64,1}}}
    levels::Union{Nothing, Dict{Int64,Array{Int64,1}}}
    u::Float64
    d::Float64
    p::Float64
    data::Union{Nothing, Dict{Int64, MyBiomialLatticeEquityNodeModel}} # holds data in the tree
    
    # constructor 
    MyBinomialEquityPriceTree() = new()
end