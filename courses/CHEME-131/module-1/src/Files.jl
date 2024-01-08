# Internal method for load a CSV file 
function _loadcsvfile(path::String)::DataFrame
    return CSV.read(path, DataFrame);
end

function _jld2(path::String)::Dict{String,Any}
    return load(path);
end

# Load harded coded specific files -
function MyTreasuryBillDataSet(;path::String = joinpath(_PATH_TO_DATA, "US-TBill-Prices-TD-Apr-2023-Jan-2024.csv"))::DataFrame
    return _loadcsvfile(path);
end