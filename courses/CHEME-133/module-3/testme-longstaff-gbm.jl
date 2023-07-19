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
K = 135.0;
T = 31.0*Δt;
r̄ = 0.0418;
σ̄ = 0.5515;

# models -
gbm_model = build(MyGeometricBrownianMotionEquityModel, (
    μ = r̄, σ = σ̄
));

# sample -
X = sample(gbm_model, (
    T₁ = 0.0, T₂ = T, Δt = Δt, Sₒ = Sₒ
), number_of_paths = 50000);

# reshape, cutoff time zero -
Ŝ = X[:,2:end] |> x-> transpose(x) |> x -> Matrix(x) |> x -> x[:,2:end]

longstaff_model = build(MyLongstaffSchwartzContractPricingModel, (
    S = Ŝ, r̄ = r̄, Δt = Δt
));

put_contract_model = build(MyEuropeanPutContractModel, (
    K = K, IV = σ̄, DTE = T, sense = 1
));

# call the longstaff code -
price_value = premium(put_contract_model, longstaff_model)

