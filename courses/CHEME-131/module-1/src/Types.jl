# setup abstract Types
abstract type AbstractTreasuryDebtSecurity end
abstract type AbstractLatticeModel end
abstract type AbstractLatticeNodeModel end

# concrete types -
mutable struct MyUSTreasuryBillModel <: AbstractTreasuryDebtSecurity
    
    # data -
    par::Float64    # Par value of the bill
    rate::Float64   # Annual interest rate
    T::Float64      # Duration in years, measured as a 365 day or a 52 week year
    
    # constructor -
    MyUSTreasuryBillModel() = new()
end

# nodes
mutable struct MyBinaryLatticeNodeModel <: AbstractLatticeNodeModel

    # data -
    probability::Float64
    rate::Float64
    price::Float64

    # constructor -
    MyBinaryLatticeNodeModel() = new();
end

# tree
mutable struct MySymmetricBinaryLatticeModel <: AbstractLatticeModel
    
    # data -
    u::Float64      # up-factor
    d::Float64      # down-factor
    p::Float64      # probability of an up move
    rₒ::Float64     # root value
    T::Int64        # number of levels in the tree (zero based)
    connectivity::Union{Nothing,Dict{Int64, Array{Int64,1}}}    # holds the connectivity of the tree
    levels::Union{Nothing,Dict{Int64,Array{Int64,1}}} # nodes on each level of the tree
    data::Union{Nothing, Dict{Int64, MyBinaryLatticeNodeModel}} # holds data in the tree

    # constructor -
    MySymmetricBinaryLatticeModel() = new()
end