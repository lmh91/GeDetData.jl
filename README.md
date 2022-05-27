# GeDetData.jl

This package gives easy access to the data of the GeDet/LEGEND group stored on CEPH.  
It is based on the [Log-dir](https://github.com/mppmu/gedet/wiki/Logdir-system) structure.

## Installation

The environment variable `GEDET_DATA_DIR` has to be set before the package is loaded.   
It has to hold the absolute path to the gedet data directory on CEPH.  
E.g. via: `bash$ export GEDET_DATA_DIR=/remote/ceph/group/gedet/data`

Install it Julia via: `using Pkg; Pkg.add(url="https://github.com/lmh91/GeDetData.jl.git")`
## Nomenclatures

### Logdir

NamedTuple of paths and basic information of a log dir.
### Dataset

Table of measurements stored inside a certain log dir.
### Measurement

NamedTuple of all important information of a single measurement of a dataset.
E.g. one hour data of a germanium detector.
Basic information are the name and the respective log dir.
Additional information and possible metadata can also be merged into the NamedTuple.

## Examples

```julia
ENV["GEDET_DATA_DIR"] = "/remote/ceph/group/gedet/data"

using GeDetData

log_dirs = GeDetData.get_log_dirs()

log_dirs_2022 = filter(c->c.year == 2022, log_dirs)
log_dirs_2021_GALATEA = filter(c->c.year == 2021 && occursin("GALATEA", c.name), log_dirs)

#Alternativ in einer Zeile
log_dirs_2021_GALATEA = GeDetData.get_log_dirs(year = 2021, name = "GALATEA")

log_dir = log_dirs_2021_GALATEA[20] 

log_dir isa GeDetData.Logdir

dataset = GeDetData.old_scala_STRUCK_dataset(log_dir)

measurement = dataset[1]
```