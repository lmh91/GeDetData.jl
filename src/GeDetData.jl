module GeDetData

    using Dates

    using TypedTables
    using Unitful


    const GEDET_DATA_DIR = ENV["GEDET_DATA_DIR"] 

    function get_lab_dir_paths()
        global GEDET_DATA_DIR
        vcat(readdir.(readdir(joinpath(GEDET_DATA_DIR::String, "lab"), join = true); join = true)...)
    end

    include("Logdir.jl")
    include("data_files_structures/data_files_structures.jl")
end 
