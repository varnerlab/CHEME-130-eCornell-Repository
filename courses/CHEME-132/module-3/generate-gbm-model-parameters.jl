# include -
include("Include.jl")

# initialize -
df = DataFrame(firm=Int64[], μ=Float64[], σ=Float64[]);

# generate data -
Δt = (1.0/252.0);
dataset = Dict{Int64,DataFrame}();
set_of_firms = generate_firm_index_set();
years = ["Year-1", "Year-2", "Year-3", "Year-4", "Year-5"];
while (isempty(set_of_firms) == false)
    firm_index = pop!(set_of_firms)
    
    for year ∈ years
        tmp_data = loaddatafile(firm=firm_index, year=year);
        
        if (haskey(dataset,firm_index) == false)
            dataset[firm_index] = tmp_data;
        else
            append!(dataset[firm_index], tmp_data)
        end
    end
end

max_number_of_records = 1256
number_of_firms = length(dataset)
for (firm_index, data) ∈ dataset
    data = dataset[firm_index];
    
    if (nrow(data) != max_number_of_records)
        delete!(dataset, firm_index);
    end
end

list_of_firm_ids = keys(dataset) |> collect |> sort;
number_of_firms = length(list_of_firm_ids);

for firm_index ∈ list_of_firm_ids

    firm_data = dataset[firm_index];
    number_of_trading_days = nrow(firm_data);

    all_range = range(1,stop=number_of_trading_days,step=1) |> collect
    T_all = all_range*Δt .- Δt;

    # Setup the normal equations -
    A = [ones(number_of_trading_days) T_all];
    Y = log.(firm_data[!,:volume_weighted_average_price]);

    # Solve the normal equations -
    θ = inv(transpose(A)*A)*transpose(A)*Y;

    # get estimated μ -
    μ̂ = θ[2];

    # compute the σ
    growth_rate_array = Array{Float64,1}(undef, number_of_trading_days-1)
    for j ∈ 2:number_of_trading_days
        
        S₁ = firm_data[j-1, :volume_weighted_average_price];
        S₂ = firm_data[j, :volume_weighted_average_price];
        growth_rate_array[j-1] = (1/Δt)*log(S₂/S₁);
    end

    R = growth_rate_array.*Δt;
    nd = fit_mle(Normal, R);
    σ̂ = params(nd) |> last |> sqrt;

    # store the data -
    result_tuple = (
        firm = firm_index,
        μ = μ̂,
        σ = σ̂
    );

    push!(df, result_tuple);
end

CSV.write(joinpath(_PATH_TO_DATA, "Parameters.csv"), df);
