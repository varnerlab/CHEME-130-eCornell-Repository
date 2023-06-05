# include the include -
include("Include.jl")

# Setup parameters -
T = 52.0
ū = 1.0326128653393791;
d̄ = 0.980236351125192;
p = 0.5502008032128514;
r̄ = 0.39
α =  0.7820;
rₒ = α*r̄*(1/T)*(1/100);

# Build the model -
model = build(MySymmetricBinaryLatticeModel,(
    u = ū, d = d̄, p = p, T = T, rₒ = rₒ
)) |> populate |> (model -> solve(model, Vₚ = 100.0));

# compute -
expected_rate_array = Array{Float64,1}()
number_of_levels = 52
for i ∈ 1:number_of_levels
    value = 𝔼(model,level=i) + 1
    push!(expected_rate_array, value)
end

