abstract type AbstractAssetModel end

"""
    mutable struct MyOrdinaryBrownianMotionEquityModel <: AbstractSecurityModel
"""
mutable struct MyOrdinaryBrownianMotionEquityModel <: AbstractAssetModel

    # data -
    μ::Float64
    σ::Float64

    # constructor -
    MyOrdinaryBrownianMotionEquityModel() = new()
end