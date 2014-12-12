#!/bin/csh
set data_dir = "/glade/scratch/pel/new_ape/"
set case = "NE30NP4_APE"
set files = `ls $data_dir/$case/*.h0.*`
echo $files
ncra $files {$case}.ave.nc
