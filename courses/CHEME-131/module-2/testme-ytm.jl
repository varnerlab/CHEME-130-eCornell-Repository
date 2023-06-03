# include -
include("Include.jl")

# setup constants -
Vₚ = 100.0
T = 5.0 # quotes are from 5/26, we are looking at the 5/15 maturation
λ = 2
r = 0.0676
c = 0.06

# this is the initial price -
Vᵦ = 96.82048850332802;

# how many coupon payments did we miss?
offset = 0;

# what compounding model are we going to use?
compound = DiscreteCompoundingModel();

# build the Bond model, we don't know the rate, but we know the price -
model = build(MyUSTreasuryCouponSecurityModel, (
    par = Vₚ, T = T, λ = λ, coupon = c
));
model.price = Vᵦ

# compute the rate -
estimated_rate = YTM(model, offset, compound);

