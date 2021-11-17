"""
    Logdir

See [Log-dir](https://github.com/mppmu/gedet/wiki/Logdir-system)
"""
const Logdir = NamedTuple{
    (:name, :year, :date, :dir_name, :abs_path), 
    Tuple{String, Int, Dates.Date, String, String}
}

const LOGDIR_PREFIX_REG = r"[0-9]{4}-[0-9]{2}-[0-9]{2}_.{8}_.{2}_"
const LOGDIR_DATE_FORMAT = DateFormat("yyyy-mm-dd")


"""
    get_log_dirs()

Returns a table of all log dirs.
"""
function get_log_dirs()
    lab_dir_paths = get_lab_dir_paths()
    filter!(path -> occursin(LOGDIR_PREFIX_REG, basename(path)), lab_dir_paths)
    basenames = basename.(lab_dir_paths)
    matches = map(bn -> match(LOGDIR_PREFIX_REG, bn), basenames)
    dates = map(m -> Date(m.match[1:10], LOGDIR_DATE_FORMAT), matches)
    Table(
        name = map(i -> basenames[i][length(matches[i].match)+1:end], eachindex(basenames)), 
        year = map(y -> y.value, Year.(dates)), 
        date = dates, 
        dir_name = basenames, 
        abs_path = lab_dir_paths
    )
end


"""
    create_log_dir(name::AbstractString; option = "lm")

Create a new log directory with substructure,\\
as defined in https://github.com/mppmu/gedet/wiki/Logdir-system,\\
in the current working directory.
"""
function create_log_dir(name::AbstractString; option = "lm")
    script_path = joinpath(dirname(@__DIR__()), "scripts", "CreateStructure.sh")
    cmd = `$(script_path) $option $name`
    run(cmd)
end


read_raw_dir(ld::Logdir)  = readdir(joinpath(ld.abs_path, "raw_data"); join = true)
read_conv_dir(ld::Logdir) = readdir(joinpath(ld.abs_path, "conv_data"); join = true)
read_cal_dir(ld::Logdir)  = readdir(joinpath(ld.abs_path, "cal_data"); join = true)
