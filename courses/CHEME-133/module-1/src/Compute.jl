# === PRIVATE BELOW HERE ============================================================================================= #
_payoff(contract::Union{MyEuropeanCallContractModel, MyAmericanCallContractModel}, S::Float64) = max(0.0, S - contract.K)
_payoff(contract::Union{MyEuropeanPutContractModel, MyAmericanPutContractModel}, S::Float64) = max(0.0, contract.K - S)
_rational(a, b) = max(a, b)
_encode(array,value) = findfirst(x->x>=value, array)

# compute the intrinsic value 
function _intrinsic(model::T, underlying::Array{Float64,1})::Array{Float64,1} where {T<:AbstractAssetModel}

    # initialize -
    intrinsic_value_array = Array{Float64,1}()

    for value ∈ underlying
        (payoff_value, _) = _expiration(model, value)
        push!(intrinsic_value_array, payoff_value)
    end

    # rerturn -
    return intrinsic_value_array
end

function _expiration(contract::Union{MyEuropeanPutContractModel, MyAmericanPutContractModel}, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.sense
    K = contract.K
    premium = contract.premium
    number_of_contracts = 1;

    # we may not have a premium yet -
    if (isnothing(premium) == true)
        premium = 0.0;
    end

    payoff_value = 0.0
    profit_value = 0.0

    # PUT contract -
    payoff_value = number_of_contracts * direction * max((K - underlying), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

    # return -
    return (payoff_value, profit_value)
end

function _expiration(contract::Union{MyEuropeanCallContractModel, MyAmericanCallContractModel}, underlying::Float64)::Tuple{Float64,Float64}

    # get data from the contract model - 
    direction = contract.sense
    K = contract.K
    premium = contract.premium
    payoff_value = 0.0
    profit_value = 0.0
    number_of_contracts = 1;

    # we may not have a premium yet -
    if (isnothing(premium) == true)
        premium = 0.0;
    end

    # PUT contract -
    payoff_value = number_of_contracts * direction * max((underlying - K), 0.0)
    profit_value = (payoff_value - direction * premium * number_of_contracts)

    # return -
    return (payoff_value, profit_value)
end

function _expiration(equity::MyEquityModel, underlying::Float64)::Tuple{Float64,Float64}

    # get data from Equity model -
    direction = equity.sense
    purchase_price = equity.purchase_price
    number_of_shares = equity.number_of_shares

    # Equity -
    payoff_value = number_of_shares * underlying
    profit_value = direction * (payoff_value - number_of_shares * purchase_price)

    # return -
    return (payoff_value, profit_value)
end

function _intrinsic(model::T, underlying::Float64)::Float64 where {T<:AbstractAssetModel}

    # compute the payoff -
    (payoff_value, _) = _expiration(model, underlying)
    return payoff_value
end
# === PRIVATE ABOVE HERE ============================================================================================= #

# === PUBLIC METHODS BELOW HERE ====================================================================================== #
𝒟(r,T) = exp(r*T);

function sample_endpoint(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)::Array{Float64,1}

    # get information from data -
    T = data[:T]
    Sₒ = data[:Sₒ]

    # get information from model -
    μ = model.μ
    σ = model.σ

	# initialize -
    X = zeros(number_of_paths) # extra column for time -

	# build a noise array of Z(0,1)
	d = Normal(0,1)
	ZM = rand(d, number_of_paths);

	# main simulation loop -
	for p ∈ 1:number_of_paths
        X[p] = Sₒ*exp((μ - σ^2/2)*T + σ*(sqrt(T))*ZM[p])
	end

	# return -
	return X
end

function sample(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
    number_of_paths::Int64 = 100)::Array{Float64,2}

    # get information from data -
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]

    # get information from model -
    μ = model.μ
    σ = model.σ

	# initialize -
	time_array = range(T₁, stop=T₂, step=Δt) |> collect
	number_of_time_steps = length(time_array)
    X = zeros(number_of_time_steps, number_of_paths + 1) # extra column for time -

    # put the time in the first col -
    for t ∈ 1:number_of_time_steps
        X[t,1] = time_array[t]
    end

	# replace first-row w/Sₒ -
	for p ∈ 1:number_of_paths
		X[1, p+1] = Sₒ
	end

	# build a noise array of Z(0,1)
	d = Normal(0,1)
	ZM = rand(d,number_of_time_steps, number_of_paths);

	# main simulation loop -
	for p ∈ 1:number_of_paths
		for t ∈ 1:number_of_time_steps-1
			X[t+1,p+1] = X[t,p+1]*exp((μ - σ^2/2)*Δt + σ*(sqrt(Δt))*ZM[t,p])
		end
	end

	# return -
	return X
end

function payoff(contracts::Array{T,1}, S::Array{Float64,1})::Array{Float64,2} where T <: AbstractContractModel

    # initialize - 
    number_of_underlying_prices = length(S);
    number_of_contracts = length(contracts);
    payoff_array = Array{Float64,2}(undef, number_of_underlying_prices, number_of_contracts+2);

    # main loop -
    for i ∈ 1:number_of_underlying_prices

        # get the underlying price -
        Sᵢ = S[i];

        # compute the payoff -
        payoff_array[i,1] = Sᵢ;

        # loop over the contracts -
        for j ∈ 1:number_of_contracts

            # get the contract -
            contract = contracts[j];
            sense = contract.sense |> Float64;
            payoff_value = _payoff(contract, Sᵢ);

            # compute the payoff -
            payoff_array[i,j+1] = (sense)*payoff_value;
        end
    end

    # compute the sum -
    for i ∈ 1:number_of_underlying_prices
        payoff_array[i,end] = sum(payoff_array[i,2:end-1]);
    end

    # return -
    return payoff_array;
end

function profit(contracts::Array{T,1}, S::Array{Float64,1})::Array{Float64,2} where T <: AbstractContractModel

    # initialize - 
    number_of_underlying_prices = length(S);
    number_of_contracts = length(contracts);
    profit_array = Array{Float64,2}(undef, number_of_underlying_prices, number_of_contracts+2);

    # main loop -
    for i ∈ 1:number_of_underlying_prices

        # get the underlying price -
        Sᵢ = S[i];

        # compute the payoff -
        profit_array[i,1] = Sᵢ;

        # loop over the contracts -
        for j ∈ 1:number_of_contracts

            # get the contract -
            contract = contracts[j];
            sense = contract.sense |> Float64;
            premium = contract.premium;

            # compute the payoff -
            profit_array[i,j+1] = (sense)*_payoff(contract, Sᵢ) - (sense)*premium
        end
    end

    # compute the sum -
    for i ∈ 1:number_of_underlying_prices
        profit_array[i,end] = sum(profit_array[i,2:end-1]);
    end

    # return -
    return profit_array;    
end


"""
    premium(contract::T, model::MyAdjacencyBasedCRREquityPriceTree; 
        choice::Function=_rational) -> Float64 where {T<:AbstractDerivativeContractModel}
"""
function premium(contract::T, model::MyAdjacencyBasedCRREquityPriceTree; 
    choice::Function=_rational)::Float64 where {T<:AbstractContractModel}

    # initialize -
    data = model.data
    connectivity = model.connectivity
    levels = model.levels

    # get stuff from the model -
    p = model.p
    μ = model.μ
    ΔT = model.ΔT
    dfactor = exp(-μ * ΔT)

    # Step 1: compute the intrinsic value
    for (_, node) ∈ data
          
        # grab the price -
        price = node.price
        node.intrinsic = _intrinsic(contract,price)
        node.extrinsic = _intrinsic(contract,price)
    end

    # get the levels that are going to process -
    list_of_levels = sort(keys(levels) |> collect,rev=true);
    for level ∈ list_of_levels[2:end]
        
        # get nodes on this level -
        parent_node_index = levels[level];
        for i ∈ parent_node_index
            
            children_nodes = connectivity[i];
            up_node_index = children_nodes[1];
            down_node_index = children_nodes[2];

            # compute the future_payback, and current payback
            current_payback = data[i].intrinsic
            future_payback = dfactor*((p*data[up_node_index].extrinsic)+(1-p)*(data[down_node_index].extrinsic))
            node_price = choice(current_payback, future_payback) # encode the choice
            data[i].extrinsic = node_price;
        end
    end

    # # return -
    return data[0].extrinsic
end

function premium(contract::MyEuropeanCallContractModel, model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)::Float64

    # get data from the contract model - 
    K = contract.K
    T = contract.DTE
    σ = contract.IV
    
    # get data from the BSM model -
    Sₒ = model.Sₒ
    r = model.r

    # compute the premium -
    d₊ = (1/σ*sqrt(T))*(log(Sₒ/K)+(r+(σ^2)/2)*T);
    d₋ = d₊ - σ*sqrt(T);
    premium = (cdf(Normal(0,1), d₊)*Sₒ - cdf(Normal(0,1), d₋)*K*(1/𝒟(r̄,T))) |> x-> round(x, sigdigits = sigdigits)

    # return -
    return premium
end

function premium(contract::MyEuropeanPutContractModel, model::MyBlackScholesContractPricingModel; sigdigits::Int64 = 4)::Float64

    # get data from the contract model - 
    K = contract.K
    T = contract.DTE
    σ = contract.IV
    
    # get data from the BSM model -
    Sₒ = model.Sₒ
    r = model.r

    # compute the premium -
    d₊ = (1/σ*sqrt(T))*(log(Sₒ/K)+(r+(σ^2)/2)*T);
    d₋ = d₊ - σ*sqrt(T);
    premium = cdf(Normal(0,1), -d₋)*K*(1/𝒟(r̄,T)) - cdf(Normal(0,1), -d₊)*Sₒ |> x-> round(x,sigdigits=sigdigits)

    # return -
    return premium
end