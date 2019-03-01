#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name (e.g., PRECT, PS)"
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname = "$argv[$n]" 

if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
  set ncl_dir = "/home/$USER/git-scripts/ncl_scripts"
  echo "You are on Hobart"
  echo "NCL directory is"$ncl_dir
endif
if (`hostname` == "cheyenne.cgd.ucar.edu") then
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif
ncl 'vname="\"$vname\""' 'vertical_height = "False"' 'case="$all_cases_ncl_string"' 'lsArg="$all_cases_ncl_files"'  'plot_dir="\"$plot_dir\""' 'plot_lat_section="True"' 'plot_lat_section_min=0' 'plot_lat_section_max=80' 'coslat="False"' 'diff="True"' 'line_colors="$line_colors"' 'lsinx = "True"' < $ncl_dir/zonal_time_avg.ncl