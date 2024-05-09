# Logbook.jl

A simple utility package with a terminal interface for logging daily events.

The idea is to maintain a logbook by writing to a CSV file with `timestamp`, `event` and `description` columns. The package can load the logbook CSV file into a data frame, to which a user can add new entries inside of an infinite loop. Adding an entry via the loop has some usability features, e.g., automatically filling in the current timestamp. Finally, the modified data frame is saved to the disk.