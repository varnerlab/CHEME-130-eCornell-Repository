# setup abstract Types
abstract type AbstractTreasuryDebtSecurity end

# concrete types -
mutable struct MyUSTreasuryBillModel <: AbstractTreasuryDebtSecurity
    
    # data -
    par::Float64    # Par value of the bill
    rate::Float64   # Annual interest rate
    T::Float64      # Duration in years, measured as a 365 day or a 52 week year

    # constructor -
    MyUSTreasuryBillModel() = new()
end