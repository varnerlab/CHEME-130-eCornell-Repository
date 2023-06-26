abstract type AbstractAssetModel end

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