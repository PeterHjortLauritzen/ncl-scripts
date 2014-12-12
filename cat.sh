#!/bin/csh
set case = "NE30NP4_APE"
set files = `ls $case.cam.h2.0000-06-*.nc`
echo $files
ncrcat $files {$case}.tmp.nc
ncks -v PRECT {$case}.tmp.nc {$case}.prect.nc
