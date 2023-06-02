# abstract types -
abstract type AbstractTreasuryDebtSecurity end

# concrete types -
"""
    MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity
"""
mutable struct MyUSTreasuryZeroCouponBondModel <: AbstractTreasuryDebtSecurity
    
    # data -
    par::Float64                                    # Par value of the bill
    rate::Float64                                   # Annual interest rate
    T::Float64                                      # Duration in years, measured as a 365 day or a 52 week year
    price::Union{Nothing, Float64}                  # Price of the bond or note
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow
    
    # constructor -
    MyUSTreasuryZeroCouponBondModel() = new()
end

"""
    MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity
"""
mutable struct MyUSTreasuryCouponSecurityModel <: AbstractTreasuryDebtSecurity

    # data -
    par::Float64                                    # Par value of the bill
    rate::Float64                                   # Annualized effective interest rate
    coupon::Float64                                 # Coupon rate
    T::Float64                                      # Duration in years, measured as a 365 day or a 52 week year
    λ::Int                                          # Number of coupon payments per year (typcially 2)
    price::Union{Nothing, Float64}                  # Price of the bond or note
    cashflow::Union{Nothing, Dict{Int,Float64}}     # Cashflow

    # consturctor -
    MyUSTreasuryCouponSecurityModel() = new();
end