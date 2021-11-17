
function get_datetime(fn::AbstractString)
	m = match(STRUCK_DATETIME_REG, fn)
    isnothing(m) && return missing
    df = DateFormat("yyyymmddTHHMMSSZ")
    DateTime(m.match[2:end], df)
end
get_datetime(m::GeDetMeasurement) = get_datetime(raw_data_filenames(m)[1])



function get_bias_voltage(fn::AbstractString)
    bv = missing
    regs = [r"_hv[-]?[0-9]*", r"HV_[-]?[0-9]*"]
    for reg in regs
        m = match(reg, fn)
        if !isnothing(m)
            try
                bv = float(parse(Int, m.match[4:end])) #* u"V"
            catch err
                continue
            end 
            break
        end
    end
    return bv
end
get_bias_voltage(m::GeDetMeasurement) = get_bias_voltage(raw_data_filenames(m)[1])