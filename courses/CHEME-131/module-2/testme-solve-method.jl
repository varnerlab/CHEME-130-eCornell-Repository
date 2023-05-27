# include -
include("Include.jl")

# setup constants -
Vₚ = 100.0
T = 30.0 # quotes are from 5/26, we are looking at the 5/15 maturation
λ = 2
r = 0.03966
c = 0.03625

# build the Bond model -
model = build(MyUSTreasuryCouponSecurityModel, (
    par = Vₚ, T = T, λ = λ, rate = r, coupon = c
));

# solve -
model = price(model, Vₚ = Vₚ)