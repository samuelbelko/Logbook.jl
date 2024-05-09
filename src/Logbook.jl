module Logbook

using DataFrames, CSV, Dates

export new_logdata_df,
    new_logdata_file,
    save_logdata,
    load_logdata,
    add_entry!,
    interactive_add_entry!,
    app!

"""
Internally, the log data is managed by having a dataframe intialized with the following columns:

    timestamp=DateTime[] 
    event=String[] 
    description=String[]
"""
const DF_COLUMN_TYPES =
    Dict(:timestamp => DateTime, :event => String, :description => String)
"""
Order of the columns.
"""
const COLUMNNAMES = [:timestamp, :event, :description]
"""
    new_logdata_df()

Create a dataframe with the column names from constant `DF_COLUMN_TYPES`, assign the column values
to an empty vector of the corresponding column types.
"""
function new_logdata_df()
    # construct from a vector of pairs to maintain the same order
    return DataFrame([
        column => Vector{DF_COLUMN_TYPES[column]}() for column in COLUMNNAMES
    ])
end

"""
    save_logdata(df, logdata_path = "./logdata.csv") 

Save `df` dataframe as a CSV file at path `logdata_path`.
"""
save_logdata(df, logdata_path = "./logdata.csv") = CSV.write(logdata_path, df)
"""
    load_logdata(logdata_path = "./logdata.csv")

Load dataframe from `logdata_path` and parse the columns according to the constant `DF_COLUMN_TYPES`.
"""
function load_logdata(logdata_path = "./logdata.csv")
    return CSV.read(logdata_path, DataFrame; types = DF_COLUMN_TYPES)
end

"""
    new_logdata_file(logdata_path="./logdata.csv")

Create and write a new log data CSV file to path `logdata_path` for reading / storing logs from / to disk.
"""
function new_logdata_file(logdata_path = "./logdata.csv")
    df = new_logdata_df()
    return save_logdata(df, logdata_path)
end

function add_entry!(df; timestamp = now(), event = "", description = "")
    return push!(df, (timestamp, event, description))
end

"""
    interactive_add_entry!(df)

Asking for user input that is than added into a data frame `df`.
"""
function interactive_add_entry!(df)
    timestamp_entry = now()
    while true
        printstyled("Enter timestamp: \n"; italic = true)
        print("> ")
        timestamp = readline()
        # pressing enter defaults to now()
        timestamp == "" && break
        try
            # entering -x means `now() - x`, `x` is in minutes
            if contains(timestamp, "-")
                m = parse(Int, timestamp)
                timestamp_entry = now() + Minute(m)
                break
            else
                h, m = parse.(Int, split(timestamp, ":"))
                timestamp_entry =
                    DateTime(year(today()), month(today()), day(today()), h, m)
                break
            end
        catch e
            println("Incorrect input. Try again. Exception: $e")
        end
    end
    event_entry = ""
    while true
        printstyled("Enter event: \n"; italic = true)
        print("> ")
        event_entry = readline()
        event_entry == "" ?
        println("Event is not allowed to be empty, try again.") : break
    end
    printstyled("Enter description: \n"; italic = true)
    print("> ")
    description_entry = readline()

    printstyled(
        "Add the above entry? [press n for no]\n";
        italic = true,
        underline = true,
    )
    print("> ")
    if readline() == "n"
        return
    else
        add_entry!(
            df;
            timestamp = timestamp_entry,
            event = event_entry,
            description = description_entry,
        )
        printstyled("Added."; italic = true)
    end
end

"""
    app!(logdata_path)

An infinite loop asking for new entries to add to a data frame loaded from a CSV file at 
`logdata_path` and finally saving it to disk.

Exit the loop via `Ctrl + c`.
"""
function app!(logdata_path)
    df = load_logdata(logdata_path)
    while true
        try
            printstyled(
                "\n" * "-"^20 * " Add new entry " * "-"^20 * "\n";
                bold = true,
            )
            interactive_add_entry!(df)
            printstyled("\n \n")
        catch e
            if e isa InterruptException
                println("\n\nExiting the interative logbook interface.")
                break
            end
        finally
            save_logdata(df, logdata_path)
        end
    end
end

end