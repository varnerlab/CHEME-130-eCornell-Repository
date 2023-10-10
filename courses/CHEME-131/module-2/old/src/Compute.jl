
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

"""
    price(model::MyUSTreasuryCouponSecurityModel, compounding::T) -> MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
"""
function price(model::MyUSTreasuryCouponSecurityModel, compounding::T)::MyUSTreasuryCouponSecurityModel where T <: AbstractCompoundingModel 
    return compounding(model)
end

# Shortcut methods
(compounding::DiscreteCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_discrete_compounding(model::MyUSTreasuryCouponSecurityModel)
(compounding::ContinuousCompoundingModel)(model::MyUSTreasuryCouponSecurityModel) = _price_continuous_compounding(model::MyUSTreasuryCouponSecurityModel)