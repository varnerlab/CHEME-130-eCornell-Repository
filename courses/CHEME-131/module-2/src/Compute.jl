"""
    price(model::MyUSTreasuryCouponSecurityModel; Vₚ::Float64 = 100.0) -> MyUSTreasuryCouponSecurityModel
"""
function price(model::MyUSTreasuryCouponSecurityModel; Vₚ::Float64 = 100.0)::MyUSTreasuryCouponSecurityModel
    
    # initialize -
    cashflow = Dict{Int,Float64}()

    # get data from the model -
    λ = model.λ
    T = model.T;
    rate = model.rate
    coupon = model.coupon

    # derived values
    N = λ*T; # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = (rate/λ);
    
    # main loop -
    for i ∈ 1:N

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