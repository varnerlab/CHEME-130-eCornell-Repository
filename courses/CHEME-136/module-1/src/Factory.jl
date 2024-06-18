function build(model::Type{M}, data::NamedTuple)::AbstractMarkovModel where {M <: AbstractMarkovModel}
    
    # initialize -
    m = model(); # build an empty model, add data to it below
    transition = Dict{Int64, Categorical}();
    emission = Dict{Int64, Categorical}();

    # get stuff from the data NamedTuple -
    states = data.states;
    T = data.T; # this is the transition matrix
    E = data.E; # this is the emission matrix

    # build the transition and emission distributions -
    for s ∈ states
        transition[s] = Categorical(T[s,:]);
        emission[s] = Categorical(E[s,:]);
    end

    # add data to the model -
    m.transition = transition;
    m.emission = emission;
    m.states = states;

    # return -
    return m;
end