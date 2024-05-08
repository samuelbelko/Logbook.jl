using Logbook
using Test
using Dates, DataFrames

df = DataFrame(timestamp=DateTime[], duration=Union{Minute,Missing}[], event=String[], description=Union{String,Missing}[])
add_entry!(df, event="breakfast")
Logbook.save_logdata(df)