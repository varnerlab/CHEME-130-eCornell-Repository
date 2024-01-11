# Include the include file -
include("Include.jl")

# initialize -
firm_index = 404;

# load the data -
years = ["Year-1", "Year-2", "Year-3", "Year-4", "Year-5"];
dataset = Dict{String,DataFrame}();
for year ∈ years
    dataset[year] = loaddatafile(firm=firm_index, year=year);
end

# combine the data -
df = dataset["Year-1"];
number_of_years = length(years);
for i ∈ 2:number_of_years
    years[i] |> (year -> append!(df, dataset[year]))
end

# load parameter df -
parameters = CSV.read(joinpath(_PATH_TO_DATA,"Parameters.csv"), DataFrame);

# idea: we do a 21-day prediction and compare it to the actual price data
number_of_trading_days = nrow(df);
T = 21
test_set = Set{StepRange{Int64,Int64}}()
for i ∈ 1:(number_of_trading_days - T)
    push!(test_set, i:i+T-1)
end

number_of_test_ranges = length(test_set);
prediction_ok_array = Array{Bool,1}(undef, number_of_test_ranges);
simulation_dictionary = Dict{Int64, Array{Float64,2}}()
for i = 1:number_of_test_ranges
    
    simrange = pop!(test_set)
    start_index = first(simrange)
    stop_index = last(simrange)

    # get the inital price -
    Sₒ = df[start_index,:volume_weighted_average_price];

    # grab the parameters -
    ū = parameters[parameters.firm .== firm_index, :up] |> first;
    d̄ = parameters[parameters.firm .== firm_index, :down] |> first;
    p̄ = parameters[parameters.firm .== firm_index, :probability] |> first;

    # build the model -
    model = build(MyBinomialEquityPriceTree, (
        u = ū, d = d̄, p = p̄)) |> (x-> populate(x, Sₒ, T));

    simulation_data_array = Array{Float64,2}(undef, T, 6);
    for i ∈ 0:(T-1)
        simulation_data_array[i+1,1] = i+start_index
        simulation_data_array[i+1,2] = df[start_index+i,:volume_weighted_average_price]
        simulation_data_array[i+1,3] = 𝔼(model,level=i);
        simulation_data_array[i+1,4] = 𝕍(model,level=i) |> sqrt;

         # compute an upper and lower bound -
        simulation_data_array[i+1,5] = simulation_data_array[i+1,3] .- 1.96*simulation_data_array[i+1,4]
        simulation_data_array[i+1,6] = simulation_data_array[i+1,3] .+ 1.96*simulation_data_array[i+1,4]
    end

    # store the simulation data -
    simulation_dictionary[i] = simulation_data_array;

    # was this a good prediction?
    L95 = simulation_data_array[:,3] .- 2.576*simulation_data_array[:,4]
    U95 = simulation_data_array[:,3] .+ 2.576*simulation_data_array[:,4]
   
    # check the bounds -
    prediction_ok = true;
    for i ∈ 1:T
        if (df[start_index+i-1,:volume_weighted_average_price] < L95[i]) || (df[start_index+i-1,:volume_weighted_average_price] > U95[i])
            prediction_ok = false;
        end
    end
    prediction_ok_array[i] = prediction_ok;
end