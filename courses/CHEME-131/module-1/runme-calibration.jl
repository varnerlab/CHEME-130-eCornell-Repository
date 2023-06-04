# include the include -
include("Include.jl")

# Setup parameters -
T = 52.0;
ū = 1.0326128653393791;
d̄ = 0.980236351125192;
p = 0.5502008032128514;
r̄ = (0.0039000000000000003)*(1/T);
Vᵦ = 99.6115;

# Build the model -
model = build(MySymmetricBinaryLatticeModel,(
    u = ū, d = d̄, p = p, T = T, rₒ = r̄
));

# calibrate the tree -
value = calibrate(model, Vᵦ)