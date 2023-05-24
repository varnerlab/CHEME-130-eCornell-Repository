function loadratesfile(; year::String = "2022")::DataFrame
    
    # check: the year four digits?
    # ...

    # build the path -
    path = joinpath(_PATH_TO_DATA, "US-daily-treasury-rates-$(year).csv")
    
    # load the data 
    return CSV.read(path,DataFrame);
end