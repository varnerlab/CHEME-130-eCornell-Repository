include("Include.jl");

# sample array from Longstaff paper -
S = [
    1.0 1.09 1.08 1.34 ;
    1.0 1.16 1.26 1.54 ;
    1.0 1.22 1.07 1.03 ;
    1.0 0.93 0.97 0.92 ;
    1.0 1.11 1.56 1.52 ;
    1.0 0.76 0.77 0.90 ;
    1.0 0.92 0.84 1.01 ;
    1.0 0.88 1.22 1.34 ;
];

Ŝ = S[:,2:end]; # cutoff the zero col

# parameters -
K = 1.10;
r̄ = 0.06;
Δt = 1.0;

# build the Longstaff model -
model = build(MyLongstaffSchwartzContractPricingModel, (
    S = Ŝ, r̄ = r̄, Δt = Δt
));

# build contract model -
put_contract_model = build(MyAmericanPutContractModel, (
    K = K, sense = 1, DTE = 4
));

# call the longstaff code -
price_value = premium(put_contract_model, model)