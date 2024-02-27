function _build(modeltype::Type{T}, data::NamedTuple) where T <: AbstractTreasuryDebtSecurity
    
    # build an empty model
    model = modeltype();

    # if we have options, add them to the contract model -
    if (isempty(data) == false)
        for key ∈ fieldnames(modeltype)
            
            # check the for the key - if we have it, then grab this value
            value = nothing
            if (haskey(data, key) == true)
                # get the value -
                value = data[key]
            end

            # set -
            setproperty!(model, key, value)
        end
    end
 
    # return -
    return model
end

# == PUBLIC METHODS BELOW HERE ======================================================================================================== #
"""
    build(model::Type{MyUSTreasuryCouponSecurityModel}, data::NamedTuple) -> MyUSTreasuryCouponSecurityModel
"""
build(model::Type{MyUSTreasuryCouponSecurityModel}, data::NamedTuple)::MyUSTreasuryCouponSecurityModel = _build(model, data);

"""
    build(model::Type{MyUSTreasuryZeroCouponBondModel}, data::NamedTuple) -> MyUSTreasuryZeroCouponBondModel
"""
build(model::Type{MyUSTreasuryZeroCouponBondModel}, data::NamedTuple)::MyUSTreasuryZeroCouponBondModel = _build(model, data);
# == PUBLIC METHODS ABOVE HERE ======================================================================================================== #