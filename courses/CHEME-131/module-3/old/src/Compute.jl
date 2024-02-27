function _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)

    # initialize -
    cashflow = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    rate = model.rate
    coupon = model.coupon

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = rate;

    # internal timescale -
    Δ = 1/λ;

    # main loop -
    for i ∈ 1:N

        # update the internal timescale -
        τ = (i)*Δ;

        # build the discount rate -
        𝒟ᵢ = exp(τ*rᵢ);

        # compute the coupon payments -
        payment =  (1/𝒟ᵢ)*Cᵢ;

        if (i == N)
            cashflow[i] = payment + (1/𝒟ᵢ)*Vₚ;
        else
            cashflow[i] = payment;     
        end
    end

    # compute the sum -
    cumulative_sum = 0.0
    for i ∈ 1:N
        cumulative_sum += cashflow[i]
    end
    cashflow[0] = -1*cumulative_sum

    # add stuff to model -
    model.cashflow = cashflow;
    model.price = abs(cashflow[0]);

    # return the updated model -
    return model
end

function _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
    
    # initialize -
    cashflow = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    rate = model.rate
    coupon = model.coupon

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = (rate/λ);

    # internal timescale -
    Δ = 1/λ;

    # main loop -
    for i ∈ 1:N

        # update the internal timescale -
        τ = (i)*Δ;

        # build the discount rate -
        𝒟ᵢ = (1+rᵢ)^i
        
        # compute the coupon payments -
        payment =  (1/𝒟ᵢ)*Cᵢ;

        if (i == N)
            cashflow[i] = payment + (1/𝒟ᵢ)*Vₚ;
        else
            cashflow[i] = payment;     
        end
    end

    # compute the sum -
    cumulative_sum = 0.0
    for i ∈ 1:N
        cumulative_sum += cashflow[i]
    end
    cashflow[0] = -1*cumulative_sum

    # add stuff to model -
    model.cashflow = cashflow;
    model.price = abs(cashflow[0]);

    # return the updated model -
    return model
end

function _price_continuous_compounding(model::MyUSTreasuryZeroCouponBondModel)

    # get data from the model -
    T = model.T;
    rate = model.rate
    Vₚ = model.par

    # compute the discount factor -
    𝒟 = exp(rate*T);

    # compute the price -
    price = (1/𝒟)*Vₚ

    # update the model -
    model.price = price;

    # return the updated model -
    return model
end

function _price_discrete_compounding(model::MyUSTreasuryZeroCouponBondModel)
    
    # get data from the model -
    T = model.T;
    rate = model.rate
    Vₚ = model.par

    # compute the discount factor -
    𝒟 = (1+rate)^(T)

    # compute the price -
    price = (1/𝒟)*Vₚ

    # update the model -
    model.price = price;

    # return -
    return model
end

# Shortcut methods that map to a 
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_discrete_compounding(model::MyUSTreasuryZeroCouponBondModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryZeroCouponBondModel) = _price_continuous_compounding(model::MyUSTreasuryZeroCouponBondModel)

# == PUBLIC METHODS BELOW HERE ======================================================================================================== #
"""
    price(model::MyUSTreasuryCouponSecurityModel, compounding::T) -> MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
"""
function price(model::MyUSTreasuryCouponSecurityModel, compounding::T)::MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
    return compounding(model)
end

"""
    price(model::MyUSTreasuryCouponSecurityModel, compounding::T) -> MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
"""
function price(model::MyUSTreasuryZeroCouponBondModel, compounding::T)::MyUSTreasuryZeroCouponBondModel where T <: AbstractCompoundingModel 
    return compounding(model)
end

"""
    strip(model::MyUSTreasuryCouponSecurityModel) -> Dict{Int, MyUSTreasuryZeroCouponBondModel}

Strips the coupon and par value payments from a parent coupon security. 

The `strip(...)` function takes a `model::MyUSTreasuryCouponSecurityModel` of the security we wish to strip and returns a [Dictionary](https://docs.julialang.org/en/v1/base/collections/#Dictionaries) 
holding `MyUSTreasuryZeroCouponBondModel` instances created from the parent security. 
The keys of the dictionary correspond to the temporal index of the created security.
"""
function strip(model::MyUSTreasuryCouponSecurityModel)::Dict{Int, MyUSTreasuryZeroCouponBondModel}

    # initialize -
    strips_dictionary = Dict{Int64,MyUSTreasuryZeroCouponBondModel}()

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    coupon = model.coupon
    Vₚ = model.par;

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ; # this becomes the new face value 

    # main loop -
    T′ = 0.0;
    for i ∈ 1:N
        
        # update the time -
        T′ += 1.0/λ;

        # build a zero-coupon bond -
        zero_model = build(MyUSTreasuryZeroCouponBondModel, (
            par = Cᵢ, T = T′
        ))

        # store -
        strips_dictionary[i] = zero_model;
    end

    # add a final zero coupon bond model that returns the face value -
    final_zero_model = build(MyUSTreasuryZeroCouponBondModel, (
        par = Vₚ, T = T
    ))

    strips_dictionary[N+1] = final_zero_model;

    # return -
    return strips_dictionary
end
# == PUBLIC METHODS ABOVE HERE ======================================================================================================== #