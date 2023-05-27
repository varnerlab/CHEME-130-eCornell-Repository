# include -
include("Include.jl")

# setup constants -
Vₚ = 100000.0
T = 5.0 # quotes are from 5/26, we are looking at the 5/15 maturation
λ = 2
r = 0.07
c = 0.08

# build the Bond model -
model = build(MyUSTreasuryCouponSecurityModel, (
    par = Vₚ, T = T, λ = λ, rate = r, coupon = c
));

# solve -
cfd = solve(model, Vₚ = Vₚ)