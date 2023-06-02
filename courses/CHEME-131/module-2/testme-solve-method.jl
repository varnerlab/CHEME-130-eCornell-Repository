# include -
include("Include.jl")

# setup constants -
Vₚ = 100.0
T = 5.0 # quotes are from 5/26, we are looking at the 5/15 maturation
λ = 2
r = 0.03985
c = 0.02875

# what compounding model are we going to use?
compounding = DiscreteCompoundingModel();

# build the Bond model -
model = build(MyUSTreasuryCouponSecurityModel, (
    par = Vₚ, T = T, λ = λ, rate = r, coupon = c
)) |> (x->price(x,compounding,Vₚ = Vₚ))

# # solve -
# model = price(model, Vₚ = Vₚ)