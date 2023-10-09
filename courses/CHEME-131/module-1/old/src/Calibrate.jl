
function _fitness(κ, model::MySymmetricBinaryLatticeModel, V::Float64)

    # grab the discount rate from the κ array -
	alpha = κ[1]

    # what is my current interest rate in the model -
    rₒ = model.rₒ;
    r′ = alpha*rₒ;

    # set on the model -
    model.rₒ = r′
	
    # populate -
    populate(model) |> (model -> solve(model, Vₚ = 100.0));
	
    # get the predicted price -
    V̂ = model.data[0].price;

    @show (V̂,V)

    # compute the squared difference -
    return 1000*(V - V̂)^2
end

"""
    calibrate(model:MySymmetricBinaryLatticeModel, rₒ::Float64) -> Float64
"""
function calibrate(model::MySymmetricBinaryLatticeModel, V::Float64)::Float64

    # initialize -    
    xinitial = [0.265]
	
    # setup bounds -
    L = 0.00001
    U = 0.99999

    # setup the objective function -
    OF(p) = _fitness(p, model, V)

    # call the optimizer -
    opt_result = optimize(OF, L, U, xinitial, Fminbox(BFGS()))

    # grab the solution -
    bgfs_soln = Optim.minimizer(opt_result)[1]

    # return -
    return bgfs_soln
end