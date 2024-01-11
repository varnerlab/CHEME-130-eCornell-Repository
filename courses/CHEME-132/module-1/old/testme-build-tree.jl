include("Include.jl")

# build a lattice model -
# initialize -
Sₒ = 100.0;
T = 3;
u = 1.01;
d = 1/u;
p = 0.51;

# build CRR model -
my_lattice_model = build(MyBinomialEquityPriceTree, (
    u = u, # a 1% increase in the price
    d = d, # 1/u
    p = p  # bias toward price increase

)) |> (x-> populate(x, Sₒ, T));