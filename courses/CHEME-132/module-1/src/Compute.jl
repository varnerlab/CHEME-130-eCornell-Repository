"""
    _build_nodes_level_dictionary(levels::Int64) -> Dict{Int64,Array{Int64,1}}
"""
function _build_nodes_level_dictionary(levels::Int64)::Dict{Int64,Array{Int64,1}}

    # initialize -
    index_dict = Dict{Int64, Array{Int64,1}}()

    counter = 0
    for l = 0:levels
        
        # create index set for this level -
        index_array = Array{Int64,1}()
        for _ = 1:(l+1)
            counter = counter + 1
            push!(index_array, counter)
        end

        index_dict[l] = (index_array .- 1) # zero based
    end

    # return -
    return index_dict
end

function _build_connectivity_dictionary(h::Int)::Dict{Int64, Array{Int64,1}}

    # compute connectivity - 
    number_items_per_level = [i for i = 1:(h+1)]
    tmp_array = Array{Int64,1}()
    theta = 0
    for value in number_items_per_level
        for _ = 1:value
            push!(tmp_array, theta)
        end
        theta = theta + 1
    end

    N = sum(number_items_per_level[1:(h)])
    connectivity_index_array = Array{Int64,2}(undef, N, 3)
    for row_index = 1:N

        # index_array[row_index,1] = tmp_array[row_index]
        connectivity_index_array[row_index, 1] = row_index
        connectivity_index_array[row_index, 2] = row_index + 1 + tmp_array[row_index]
        connectivity_index_array[row_index, 3] = row_index + 2 + tmp_array[row_index]
    end
    
    # adjust for zero base -
    zero_based_array = connectivity_index_array .- 1;

    # build connectivity dictionary -
    N = sum(number_items_per_level[1:end-1])
    connectivity = Dict{Int64, Array{Int64,1}}()
    for i ∈ 0:(N-1)
        # grab the connectivity -
        connectivity[i] = reverse(zero_based_array[i+1,2:end])
    end

    # put it back in order -
    for i ∈ 0:(N-1)
        # grab the connectivity -
        connectivity[i] = zero_based_array[i+1,2:end]
    end

    return connectivity
end

# define expectation -
_𝔼(X::Array{Float64,1}, p::Array{Float64,1}) = sum(X.*p)

"""
    populate(model::MyCRRPriceLatticeModel, Sₒ::Float64, T::Int) -> Dict{Int,Array{NamedTuple,1}}
"""
function populate(model::MyBinomialEquityPriceTree, Sₒ::Float64, h::Int)::MyBinomialEquityPriceTree

    # initialize -
    u = model.u;
    p = model.p;
    d = model.d;
    data = Dict{Int,Array{MyBiomialLatticeEquityNodeModel,1}}() # the node model holds two pieces of data: S is the price, P is the probability of that price

    # main loop -
    for t ∈ 0:h
        
        # prices -
        node_array = Array{MyBiomialLatticeEquityNodeModel,1}()
        for k ∈ 0:t
            
            t′ = big(t)
            k′ = big(k)

            # compute the prices and P for this level
            price = Sₒ*(u^(t-k))*(d^(k));
            P = binomial(t′,k′)*(p^(t-k))*(1-p)^(k);

            # create a NamedTuple that holds values
            node = MyBiomialLatticeEquityNodeModel()
            node.price = price
            node.probability = P
          
            # push this into the array -
            push!(node_array, node)
        end

        # grab -
        data[t] = node_array;
    end

    # update the model -
    model.data = data;
    model.levels = _build_nodes_level_dictionary(h);
    model.connectivity = _build_connectivity_dictionary(h);

    # return -
    return model
end


"""
    entropy(data::Dict{Int,Array{NamedTuple,1}}, level::Int) -> Float64
"""
function entropy(data::Dict{Int,Array{NamedTuple,1}}, level::Int)::Float64

    # initialize -
    H = 0.0;

    # Hint: to compute log to the base 2, check out the log2 method

    # entropy
    # grab the values for level -
    prices = data[level];
    for price_tuple ∈ prices
    
        # get the probability -
        P = price_tuple.P;
        H += P*log2(P)
    end
    
    # return -
    return -1*H
end

"""
    𝔼(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64
"""
function 𝔼(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # initialize -
    expected_value = 0.0;
    X = Array{Float64,1}();
    p = Array{Float64,1}();

    # get the levels dictionary -
    levels = model.levels;
    nodes_on_this_level = levels[level]
    for i ∈ nodes_on_this_level

        # grab the node -
        node = model.data[i];
        
        # get the data -
        x_value = node.price;
        p_value = node.probability;

        # store the data -
        push!(X,x_value);
        push!(p,p_value);
    end

    # compute -
    expected_value = _𝔼(X,p) # inner product

    # return -
    return expected_value
end

"""
    𝕍(model::MyBinomialEquityPriceTree; level::Int = 0) -> Float64
"""
function 𝕍(model::MyBinomialEquityPriceTree; level::Int = 0)::Float64

    # initialize -
    variance_value = 0.0;
    X = Array{Float64,1}();
    p = Array{Float64,1}();

    # get the levels dictionary -
    levels = model.levels;
    nodes_on_this_level = levels[level]
    for i ∈ nodes_on_this_level
 
        # grab the node -
        node = model.data[i];
         
        # get the data -
        x_value = node.price;
        p_value = node.probability;
 
        # store the data -
        push!(X,x_value);
        push!(p,p_value);
    end

    # update -
    variance_value = (_𝔼(X.^2,p) - (_𝔼(X,p))^2)

    # return -
    return variance_value;
end