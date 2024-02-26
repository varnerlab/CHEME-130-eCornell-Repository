include("Include.jl");

# parameters -
# Δt = (1.0/365.0);
# Sₒ = 59.0;
# K = 60.0;
# T = 365.0*Δt;
# r̄ = 0.05;
# σ̄ = 0.10;

# AMD -
Δt = (1.0/365.0);
Sₒ = 117.50;
K = 160.0;
T = 31.0*Δt;
r̄ = 0.0418;
σ̄ = 0.5175;


# models -

# sample -
gbm_model = build(MyGeometricBrownianMotionEquityModel, (
    μ = r̄, σ = σ̄
));
X1 = sample(gbm_model, (
    T₁ = 0.0, T₂ = T, Δt = Δt, Sₒ = Sₒ
), number_of_paths = 25000);


gbm_model_2 = build(MyGeometricBrownianMotionEquityModel, (
    μ = r̄, σ = 0.5*σ̄
));

X2 = sample(gbm_model_2, (
    T₁ = 0.0, T₂ = T, Δt = Δt, Sₒ = Sₒ
), number_of_paths = 25000);

# reshape, cutoff time zero -
Ŝ1 = X1[:,2:end] |> x-> transpose(x) |> x -> Matrix(x) |> x -> x[:,2:end]
Ŝ2 = X2[:,2:end] |> x-> transpose(x) |> x -> Matrix(x) |> x -> x[:,2:end]

Ŝ = [Ŝ1 ; Ŝ2]

# build the longstaff -
longstaff_model = build(MyLongstaffSchwartzContractPricingModel, (
    S = Ŝ, r̄ = r̄, Δt = Δt
));

# load the data -
df_data = CSV.read(joinpath(_PATH_TO_DATA, "AMD-options-exp-2023-08-18-monthly-07-18-2023.csv"), DataFrame);

start_strike = 60.0;
stop_strike = 160.0;
K = range(start_strike, stop = stop_strike, step=1) |> collect;
dataset = filter([:Type, :Strike] => (x,y)-> x == "Put" && y ∈ K, df_data);
df_sim = DataFrame(K=Float64[], premium = Float64[])
for value ∈ K
    
    # compute the IV -
    tmp = dataset[dataset.Strike .== value, :IV]
    IV_value = 0.5175;
    if (isempty(tmp) == false)
        IV_value = first(tmp);
    end

    # contract -
    put_contract_model = build(MyAmericanPutContractModel, (
        K = value, IV = first(IV_value), DTE = T, sense = 1
    ));

    # call the longstaff code -
    price_value = premium(put_contract_model, longstaff_model)

    # grab -
    results_tuple = (
        K = value,
        premium = price_value
    );
    push!(df_sim, results_tuple);

    @show value
end

