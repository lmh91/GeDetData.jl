using Test
#= 
    Tests will only run through if 
    `ENV["GEDET_DATA_DIR"]` is mounted.
=#

ENV["GEDET_DATA_DIR"] = "/remote/ceph/group/gedet/data"

using GeDetData

log_dirs = GeDetData.get_log_dirs()

log_dirs_2021_GALATEA = filter(c->c.year == 2021 && occursin("GALATEA", c.name), log_dirs)
log_dirs_2022 = filter(c->c.year == 2022, log_dirs)

log_dir = log_dirs_2021_GALATEA[20] 

@testset "Logdir" begin
    @test log_dir isa GeDetData.Logdir
end