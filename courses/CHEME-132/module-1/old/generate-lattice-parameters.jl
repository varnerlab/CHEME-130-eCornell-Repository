# include -
include("Include.jl")

# initialize -
df = DataFrame(firm=Int64[], up=Float64[], down=Float64[], probability=Float64[]);

# generate the firm index set -
firm_index_set = generate_firm_index_set()

# process each firm -
years = ["Year-1", "Year-2", "Year-3", "Year-4", "Year-5"];
for firm_index ∈ firm_index_set

    # load the data -
    dataset = Dict{String,DataFrame}();
    for year ∈ years
        dataset[year] = loaddatafile(firm=firm_index, year=year);
    end

    # combine the data -
    tmp = dataset["Year-1"];
    number_of_years = length(years);
    for i ∈ 2:number_of_years
        years[i] |> (year -> append!(tmp, dataset[year]))
    end

    # compute the returns -
    Δt = (1.0/365.0);
    number_of_trading_days = nrow(tmp);
    return_array = Array{Float64,1}(undef, number_of_trading_days-1)
    for j ∈ 2:number_of_trading_days
    
        S₁ = tmp[j-1,:volume_weighted_average_price];
        S₂ = tmp[j,:volume_weighted_average_price];
        return_array[j-1] = (1/Δt)*log(S₂/S₁);
    end

    # analyze the returns -
    (ū,d̄,p̄) = analyze(return_array, Δt = Δt);

    # store the data -
    results_tuple = (
        firm = firm_index,
        up = ū,
        down = d̄,
        probability = p̄
    );
    push!(df, results_tuple);
end

# dump -
CSV.write(joinpath(_PATH_TO_DATA,"Parameters.csv"), df);