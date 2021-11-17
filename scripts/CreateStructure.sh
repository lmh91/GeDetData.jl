#!/bin/bash 

option=$1

test_name=$2

# /.hb/raidg01/sw/scripts/bin/gedet-logdir.sh create $option $test_name
$( dirname -- "$0"; )/gedet-logdir.sh create $option $test_name

dir=`echo *$option*$test_name*`

name=$PWD/$dir

mkdir $name/raw_data
mkdir $name/conv_data
mkdir $name/cal_data
mkdir $name/config_file
mkdir $name/pictures
mkdir $name/jsons
mkdir $name/quality_check
mkdir $name/lifetimes

cd $name
#chmod og=rwx *
chmod g=rwx *
cd -

#chmod 777 -R $name
