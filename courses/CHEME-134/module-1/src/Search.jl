function search(dataset::Dict{Int64, Vector{Dict{String, Any}}}, DTE::Int64, logic::Function)

    # initialize -
    results = DataFrame();

    # iterate over the dataset -
    records = dataset[DTE];
    for record in records

        if (logic(record) == true)

            # @show record["details"]
            
            # capture data from the record -
            row_df = (
                underlying = record["underlying_asset"]["price"],
                strike = record["details"]["strike_price"] |> x-> convert(Float64, x),
                type = record["details"]["contract_type"],
                bid = record["last_quote"]["bid"],
                ask = record["last_quote"]["ask"],
                midpoint = record["last_quote"]["midpoint"]
            );


            push!(results, row_df);
        end
    end

    return results;
end