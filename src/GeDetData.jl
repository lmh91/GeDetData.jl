module GeDetData

    using Dates

    using TypedTables
    using Unitful


    const GEDET_DATA_DIR = ENV["GEDET_DATA_DIR"] 
    

    include("Logdir.jl")
    include("data_files_structures/data_files_structures.jl")
end 
