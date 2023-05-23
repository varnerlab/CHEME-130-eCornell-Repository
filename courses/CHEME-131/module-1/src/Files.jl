function loadratesfile(; path::String = joinpath(_PATH_TO_DATA, "US-daily-treasury-rates-2022.csv"))::DataFrame
    return CSV.read(path,DataFrame);
end