function _net_present_value(r::Float64, model::MyUSTreasuryCouponSecurityModel, 
    compounding::DiscreteCompoundingModel)

    # initialize -
    cashflow = Dict{Int,Float64}();

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    coupon = model.coupon
    price = model.price; # the price is set, we are looking for the interest rate

    # we are passing in the rate -
    rate = r;

    # derived values
    N = round(Int,λ*T); # the number of steps we take
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
   
    # compute the npv value -
    npv_value = (cumulative_sum - price)

    # return -
    return npv_value
end

function _net_present_value(r::Float64, model::MyUSTreasuryCouponSecurityModel, 
    compounding::ContinuousCompoundingModel)

    # initialize -
    cashflow = Dict{Int,Float64}();

    # get data from the model -
    λ = model.λ  # per year
    T = model.T;
    coupon = model.coupon
    price = model.price; # the price is set, we are looking for the interest rate

    # we are passing in the rate -
    rate = r;

    # derived values
    N = round(Int,λ*T); # the number of steps we take
    Cᵢ = (coupon/λ)*Vₚ;
    rᵢ = (rate);

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
   
    # compute the npv value -
    npv_value = (cumulative_sum - price)

    # return -
    return npv_value
end


function _fitness(κ, model::MyUSTreasuryCouponSecurityModel, compounding::T) where T <: AbstractCompoundingModel

    # grab the discount rate from the κ array -
	discount_rate = κ[1]
	
	# we need to min the NPV - 
	npv_value = _net_present_value(discount_rate, model, compounding)

	# return the fitness -
	return (npv_value)^2
end

"""
    YTM(model::MyUSTreasuryCouponSecurityModel, compounding::T, offset::Int64; rₒ::Float64 = 0.01) where T <: AbstractCompoundingModel
"""
function YTM(model::MyUSTreasuryCouponSecurityModel, compounding::T; rₒ::Float64 = 0.01) where T <: AbstractCompoundingModel

    # initialize -    
    xinitial = [rₒ]
	
	# setup bounds -
	L = 0.00001
	U = 0.99999
	
	# setup the objective function -
	OF(p) = _fitness(p, model, compounding)
    
    # call the optimizer -
    opt_result = optimize(OF, L, U, xinitial, Fminbox(BFGS()))

    # grab the solution -
    bgfs_soln = Optim.minimizer(opt_result)[1]

    # return -
    return bgfs_soln
end