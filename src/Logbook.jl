module Logbook

using DataFrames, CSV, Dates

export new_logdata_df,
    add_entry!,
    save_logdata,
    load_logdata,
    new_logdata_file,
    interactive_add_entry!

"""
Internally, the log data is managed by having a dataframe intialized with the following columns:

    timestamp=DateTime[] 
    event=String[] 
    description=String[]
"""
const DF_TYPES = Dict(
    :timestamp => DateTime,
    :event => String,
    :description => String,
)
"""
Order of the columns.
"""
const COLUMNNAMES = [:timestamp, :event, :description]
"""
    new_logdata_df()

Create a dataframe with the column names from constant `DF_TYPES` and empty vector with 
corresponding types.
"""
function new_logdata_df()
    # construct from a vector of pairs to maintain the same order
    return DataFrame([
        column => Vector{DF_TYPES[column]}() for column in COLUMNNAMES
    ])
end

save_logdata(df, logdata_path = "./logdata.csv") = CSV.write(logdata_path, df)
function load_logdata(logdata_path = "./logdata.csv")
    return CSV.read(logdata_path, DataFrame; types = DF_TYPES)
end

"""
    new_logdata_file(logdata_path="./logdata.csv")

Create and write a new log data CSV file to path `logdata_path` for reading / storing logs from / to disk.
"""
function new_logdata_file(logdata_path = "./logdata.csv")
    df = new_logdata_df()
    return save_logdata(df, logdata_path)
end

function add_entry!(
    df;
    timestamp = now(),
    event = "",
    description = "",
)
    return push!(df, (timestamp, event, description))
end

function interactive_add_entry!(df, logdata_path = "./logdata.csv")
    timestamp_entry = now()
    while true
        print("Enter timestamp: ")
        timestamp = readline()
        # pressing enter defaults to now()
        timestamp == "" && break
        try
            h, m = parse.(Int, split(timestamp, ":"))
            timestamp_entry =
                DateTime(year(today()), month(today()), day(today()), h, m)
            break
        catch e
            println("Incorrect input. Try again. Exception: $e")
        end
    end
    print("Enter event: ")
    event_entry = readline()
    print("Enter description: ")
    description_entry = readline()

    add_entry!(
        df;
        timestamp = timestamp_entry,
        event = event_entry,
        description = description_entry,
    )
    return printstyled("An entry was added.", italic=true)
end

end