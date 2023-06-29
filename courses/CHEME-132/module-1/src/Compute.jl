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
    nodes_dictionary = Dict{Int, MyBiomialLatticeEquityNodeModel}()

    # main loop -
    counter = 0;
    for t ∈ 0:h
        
        # prices -
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
            nodes_dictionary[counter] = node;
            counter += 1
        end
    end

    # update the model -
    model.data = nodes_dictionary;
    model.levels = _build_nodes_level_dictionary(h);
    model.connectivity = _build_connectivity_dictionary(h);

    # return -
    return model
end

function sample(model::MyBinomialEquityPriceTree; number_of_paths::Int64 = 100)::Array{Float64,2}

    # initialize -
    levels = model.levels;
    data = model.data;
    h = length(levels)-1;

    # initialize -
    X = Array{Float64,2}(undef, h+1, number_of_paths);
    X[1,:] .= data[0].price;

    for i ∈ 1:number_of_paths
        for t ∈ 1:h

            # get the list of nodes -
            list_of_nodes = levels[t];

            # create a categorical distribution -
            pvector = Array{Float64,1}()
            for node_index ∈ list_of_nodes
                node = data[node_index];
                push!(pvector, node.probability)
            end
            d = Categorical(pvector);

            # sample from the distribution -
            random_node_index = rand(d);
            price = data[random_node_index].price;

            # store the price -
            X[t+1,i] = price;
        end
    end

    # return -
    return X
end



# """
#     entropy(data::Dict{Int,Array{NamedTuple,1}}, level::Int) -> Float64
# """
# function entropy(data::Dict{Int,Array{NamedTuple,1}}, level::Int)::Float64

#     # initialize -
#     H = 0.0;

#     # Hint: to compute log to the base 2, check out the log2 method

#     # entropy
#     # grab the values for level -
#     prices = data[level];
#     for price_tuple ∈ prices
    
#         # get the probability -
#         P = price_tuple.P;
#         H += P*log2(P)
#     end
    
#     # return -
#     return -1*H
# end

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
    𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; 
        startindex::Int64 = 0) -> Array{Float64,2}

Computes the expectation of the model simulation. Takes a model::MyBinomialEquityPriceTree instance and a vector of
tree levels, i.e., time steps and returns a variance array where the first column is the time and the second column is the expectation.
Each row is a time step.
"""
function 𝔼(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; 
    startindex::Int64 = 0)::Array{Float64,2}

    # initialize -
    number_of_levels = length(levels);
    expected_value_array = Array{Float64,2}(undef, number_of_levels, 2);

    # loop -
    for i ∈ 0:(number_of_levels-1)

        # get the level -
        level = levels[i+1];

        # get the expected value -
        expected_value = 𝔼(model, level=level);

        # store -
        expected_value_array[i+1,1] = level + startindex;
        expected_value_array[i+1,2] = expected_value;
    end

    # return -
    return expected_value_array;
end

Var(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) = 𝕍(model, levels, startindex = startindex)

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

"""
    𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0) -> Array{Float64,2}

Computes the variance of the model simulation. Takes a model::MyBinomialEquityPriceTree instance and a vector of
tree levels, i.e., time steps and returns a variance array where the first column is the time and the second column is the variance.
Each row is a time step.
"""
function 𝕍(model::MyBinomialEquityPriceTree, levels::Array{Int64,1}; startindex::Int64 = 0)::Array{Float64,2}

    # initialize -
    number_of_levels = length(levels);
    variance_value_array = Array{Float64,2}(undef, number_of_levels, 2);

    # loop -
    for i ∈ 0:(number_of_levels - 1)
        level = levels[i+1];
        variance_value = 𝕍(model, level=level);
        variance_value_array[i+1,1] = level + startindex
        variance_value_array[i+1,2] = variance_value;
    end

    # return -
    return variance_value_array;
end


"""
    analyze(R::Array{Float64,1};  Δt::Float64 = (1.0/365.0)) -> Tuple{Float64,Float64,Float64}
"""
function analyze(R::Array{Float64,1};  Δt::Float64 = (1.0/365.0))::Tuple{Float64,Float64,Float64}
    
    # initialize -
    u,d,p = 0.0, 0.0, 0.0;
    darray = Array{Float64,1}();
    uarray = Array{Float64,1}();
    N₊ = 0;

    # up -
    # compute the up moves, and estimate the average u value -
    index_up_moves = findall(x->x>0, R);
    for index ∈ index_up_moves
        R[index] |> (μ -> push!(uarray, exp(μ*Δt)))
    end
    u = mean(uarray);

    # down -
    # compute the down moves, and estimate the average d value -
    index_down_moves = findall(x->x<0, R);
    for index ∈ index_down_moves
        R[index] |> (μ -> push!(darray, exp(μ*Δt)))
    end
    d = mean(darray);

    # probability -
    N₊ = length(index_up_moves);
    p = N₊/length(R);

    # return -
    return (u,d,p);
end

"""
    generate_firm_index_set() -> Set{Int64}

Generates a set of firm indexes in the data set
"""
function generate_firm_index_set()::Set{Int64}

    # initialize -
    list_of_files = readdir(joinpath(_PATH_TO_DATA,"Year-1"), join=true);
    set_of_firm_indexes = Set{Int64}();

    for file ∈ list_of_files

        # get the file name -
        file_name = basename(file);
        if (file_name != ".ipynb_checkpoints")
            
            # get the firm index -
            components = split(file_name,"-")[2] |> (x-> split(x,"."))
            firm_index = parse(Int64, String.(components) |> (x -> x[1]));
    
            # push -
            push!(set_of_firm_indexes, firm_index);
        end
    end

    # delete 268, doesn't exist in Y5
    set_of_firm_indexes |> (x -> delete!(x, 268))

    # return -
    return set_of_firm_indexes;
end