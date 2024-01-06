function sample(model::EpsilonSamplingModel, world::Function, data::Dict{String,DataFrame}, tickers::Array{String,1}; 
    horizon::Int64 = 100, buffersize::Int64 = 1, risk_free_rate::Float64 = 0.05)

    # initialize -
    α = model.α
    β = model.β
    K = model.K
    ϵ = model.ϵ
    θ̂_vector = Array{Float64,1}(undef, K)
    time_sample_results_dict_Ts = Dict{Int64, Array{Float64,2}}();
    action_distribution = Array{Beta,1}(undef, K);

    # generate random Categorical distribution -
    parray = [1/K for _ = 1:K]
    dcat = Categorical(parray);
    
    # initialize collection of Beta distributions -
    foreach(k -> action_distribution[k] = Beta(α[k], β[k]), 1:K);
 
    # main sampling loop -
    for t ∈ 1:horizon

        # create a new parameter array -
        parameter_array = Array{Float64,2}(undef, K, 2);
        fill!(parameter_array, 0.0);

        # for each action, grab the parameters -
        for k ∈ 1:K
            
            # grab the distribution for action k -
            d = action_distribution[k];

            # store the parameter array -
            αₖ, βₖ = params(d);
            parameter_array[k,1] = αₖ
            parameter_array[k,2] = βₖ

            # store -
            time_sample_results_dict_Ts[t] = parameter_array;
        end

        aₜ = nothing; # default to nothing 
        if (rand() < ϵ)
            aₜ = rand(dcat); # choose a random action uniformly
        else
            
            for k ∈ 1:K

                # grab the distribution for action k -
                d = action_distribution[k];
    
                # generate a sample for this action -
                θ̂_vector[k] = rand(d);
            end

            # ok: let's choose an action -
            aₜ = argmax(θ̂_vector);

            # pass that action to the world function, gives back a reward -
            rₜ = world(aₜ, t, data, tickers; buffersize = buffersize, risk_free_rate = risk_free_rate);

            # update the parameters -
            # first, get the old parameters -
            old_d = action_distribution[aₜ];
            αₒ,βₒ = params(old_d);

            # update the old values with the new values -
            αₜ = αₒ + rₜ
            βₜ = βₒ + (1-rₜ)

            # build new distribution -
            action_distribution[aₜ] = Beta(αₜ, βₜ);
        end
    end

    return time_sample_results_dict_Ts;
end

function build_beta_array(parameters::Array{Float64,2})::Array{Beta,1}

    # build an array of beta distributions -
    (NR,_) = size(parameters);
    beta_array = Array{Beta,1}(undef,NR)
    for i ∈ 1:NR
        
        # grab the parameters -
        α = parameters[i,1];
        β = parameters[i,2];

        # build -
        beta_array[i] = Beta(α, β);
    end

    # return -
    return beta_array;
end


function preference(beta::Array{Beta,1}, tickers::Array{String,1}; N::Int64 = 100)

    # sample -
    K = length(tickers);
    θ̂_vector = Array{Float64,1}(undef, K)

    # Let's compute the mean of each beta distribution -
    for k ∈ 1:K # for each action
        
        # grab -
        d = beta[k];
        α,β = params(d);
        
        # generate a sample for this action -
        θ̂_vector[k] = (α)/(α+β);
    end

    # ok: let's choose an action -

    # return -
    return tiedrank(θ̂_vector, rev = true);
end

function log_return_matrix(dataset::Dict{String, DataFrame}, 
    firms::Array{String,1}; Δt::Float64 = (1.0/252.0), risk_free_rate::Float64 = 0.0)::Array{Float64,2}

    # initialize -
    number_of_firms = length(firms);
    number_of_trading_days = nrow(dataset["AAPL"]);
    return_matrix = Array{Float64,2}(undef, number_of_trading_days-1, number_of_firms);

    # main loop -
    for i ∈ eachindex(firms) 

        # get the firm data -
        firm_index = firms[i];
        firm_data = dataset[firm_index];

        # compute the log returns -
        for j ∈ 2:number_of_trading_days
            S₁ = firm_data[j-1, :volume_weighted_average_price];
            S₂ = firm_data[j, :volume_weighted_average_price];
            return_matrix[j-1, i] = (1/Δt)*log(S₂/S₁) - risk_free_rate;
        end
    end

    # return -
    return return_matrix;
end