""" 
    solve(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple) -> Array{Float64,2}
"""
function solve(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple; 
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

"""
    generate_firm_index_set() -> Set{Int64}
"""
function generate_firm_index_set()::Set{Int64}

    # initialize -
    list_of_files = readdir(joinpath(_PATH_TO_DATA,"Year-1"), join=true);
    set_of_firm_indexes = Set{Int64}();

    for file ∈ list_of_files

        # get the file name -
        file_name = basename(file);
        if (file_name != ".ipynb_checkpoints")
            
            # get the firm index -
            components = split(file_name,"-")[2] |> (x-> split(x,"."))
            firm_index = parse(Int64, String.(components) |> (x -> x[1]));
    
            # push -
            push!(set_of_firm_indexes, firm_index);
        end
    end

    # delete 268, doesn't exist in Y5
    set_of_firm_indexes |> (x -> delete!(x, 268))

    # return -
    return set_of_firm_indexes;
end

function 𝔼(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)::Array{Float64,2}

    # get information from data -
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]
    
    # get information from model -
    μ = model.μ

    # setup the time range -
    time_array = range(T₁,stop=T₂, step = Δt) |> collect
    Nₜ = length(time_array)

    # expectation -
    expectation_array = zeros(Nₜ, 2)

    # main loop -
    for i ∈ 1:Nₜ

        # get the time value -
        h = (time_array[i] - time_array[1])

        # compute the expectation -
        value = Sₒ*exp(μ*h)

        # capture -
        expectation_array[i,1] = h+time_array[1]
        expectation_array[i,2] = value
    end
   
    # return -
    return expectation_array
end

Var(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple) = 𝕍(model, data);
function 𝕍(model::MyGeometricBrownianMotionEquityModel, data::NamedTuple)::Array{Float64,2}

    # get information from data -
    T₁ = data[:T₁]
    T₂ = data[:T₂]
    Δt = data[:Δt]
    Sₒ = data[:Sₒ]

    # get information from model -
    μ = model.μ
    σ = model.σ

    # setup the time range -
    time_array = range(T₁,stop=T₂, step = Δt) |> collect
    Nₜ = length(time_array)

    # expectation -
    variance_array = zeros(Nₜ, 2)

    # main loop -
    for i ∈ 1:Nₜ

        # get the time value -
        h = time_array[i] - time_array[1]

        # compute the expectation -
        value = (Sₒ^2)*exp(2*μ*h)*(exp((σ^2)*h) - 1)

        # capture -
        variance_array[i,1] = h + time_array[1]
        variance_array[i,2] = value
    end
   
    # return -
    return variance_array
end