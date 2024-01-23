"""
loaddatafile(; firm::Int = 1, year::String = "2022")::DataFrame
"""
function loaddatafile(; firm::Int = 1, year::String = "2022")::DataFrame
    
    # build the path -
    path = joinpath(_PATH_TO_DATA, "$(year)", "Firm-$(firm).csv")
    
    # load the data 
    return CSV.read(path,DataFrame);
end

"""
    loadmodelparametersfile() -> DataFrame
"""
function loadmodelparametersfile()::DataFrame
    return CSV.read(joinpath(_PATH_TO_DATA,"Parameters.csv"), DataFrame);
end