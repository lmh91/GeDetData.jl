const OLD_SCALA_STRUCK_DATETIME_REG = r"-\d{8}T\d{6}Z"
const OLD_SCALA_STRUCK_MULTI_DAQ_REG = r"-adc[0-9]{1}"


"""
    old_scala_STRUCK_dataset(ld::Logdir)

Scans a log dir for measurements in the file format  
produced by old scala STRUCK script:
    * `.dat` binary files
    * `.log` log files
"""
function old_scala_STRUCK_dataset(ld::Logdir)
    global OLD_SCALA_STRUCK_DATETIME_REG, OLD_SCALA_STRUCK_MULTI_DAQ_REG
    possible_old_scala_files = filter(fn -> occursin(OLD_SCALA_STRUCK_DATETIME_REG, fn) &&
        (occursin("raw.dat", fn) || occursin(".log", fn)),
        GeDetData.read_raw_dir(ld)
    )
    possible_old_scala_log_files = filter(fn -> endswith(fn, ".log"), possible_old_scala_files)
    possible_old_scala_binary_files = filter(fn -> !endswith(fn, ".log") && occursin(".dat", fn), possible_old_scala_files)
    basenames = begin
        datetime_reg_inds = map(fn -> match(OLD_SCALA_STRUCK_DATETIME_REG, fn).offset, possible_old_scala_log_files)
        map(i -> possible_old_scala_log_files[i][1:datetime_reg_inds[i]-1], eachindex(possible_old_scala_log_files))
    end
    n_measurements = length(basenames)
    binary_files = begin
        map(basename -> filter(fn -> startswith(fn, basename), possible_old_scala_binary_files), basenames)
    end
    Table(
        name = basenames,
        logdir = [ld for i in basenames],
        old_scala_STRUCK_binary_file = binary_files,
        old_scala_STRUCK_log_file = possible_old_scala_log_files
    )
end