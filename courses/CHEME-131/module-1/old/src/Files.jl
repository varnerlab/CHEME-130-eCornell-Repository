"""
loadratesfile(; year::String = "2022")::DataFrame
"""
function loadratesfile(; year::String = "2022")::DataFrame
    
    # check: do we have the correct year?
    ok_years_set = Set(["2019", "2020", "2021", "2022", "2023"]);
    if (in(year, ok_years_set) == false)
        error("We have data for 2019, 2020, 2021, 2022 or 2023. You passed in $(year).")
    end

    # build the path -
    path = joinpath(_PATH_TO_DATA, "US-daily-treasury-rates-$(year).csv")
    
    # load the data 
    return CSV.read(path,DataFrame);
end