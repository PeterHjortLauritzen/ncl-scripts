#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is run case"
  echo "  -arg 2 is history file number (e.g., h0)"
  exit
endif
set n = 1
set case = "$argv[$n]"
set n = 2
set hn = "$argv[$n]"
#set root = "/scratch/cluster/pel"
set root = "/glade/scratch/pel"
set data_dir = "$root/$case/run"
set interp_dir =  "$root//$case/run/interp-data"
#setenv my_ncl_dir  "/home/pel/ncl_scripts"
setenv my_ncl_dir  "/glade/u/home/pel/ncl_scripts"
set work_dir  =  "$root/$case/run/work"
set plot_dir  =  "$root/$case/run/plots"



set nlon  = 360
set nlat  = 180
set interp_method = "bilinear" #patch
echo ""
echo "------------------------------------------------------------"
echo "This script interpolates the user specified cases located in"
echo ""
echo $data_dir 
echo ""
echo "to a lat-lon grid ($nlon longitudes and $nlat latitudes)" 
echo "using $interp_method interpolation"
echo "The interpolated files will be located in:"
echo ""
echo $interp_dir
echo ""
echo "------------------------------------------------------------"
echo ""
#
# $case.nc will be interpolated to latitude-longitude grid
#
set cases = ( "$case.$hn" )
#
# DO NOT EDIT BELOW
#
if (! -e $plot_dir) mkdir $plot_dir
if (! -e $work_dir) mkdir $work_dir
if (! -e $interp_dir) mkdir $interp_dir
foreach case ($cases)
  foreach file (`ls $data_dir/$case.nc | grep -v ''$interp_method'_to_nlon'$nlon'xnlat'$nlat'.nc'`)
    #*********************************************
    #
    # interpolate data
    #
    #*********************************************
    setenv interpfile  {$case}.nc.{$interp_method}_to_nlon{$nlon}xnlat{$nlat}.nc
    if (-e $interp_dir/$interpfile) then
      echo "Skipping interpolating ($interpfile exists)"
    else
      echo "Creating "$interpfile
      if (! -e $work_dir/Regrid_Maps) then
         mkdir $work_dir/Regrid_Maps
      endif
      if (-e $work_dir/$case.regrid.sh) rm $work_dir/$case.regrid.sh
      if (-e $work_dir/$case.regrid.sh.output) rm $work_dir/$case.regrid.sh.output
      echo "ncl  'case="\"$case.nc\""' 'ingrid="\"$case\""' 'outgrid="\"nlon{$nlon}xnlat{$nlat}\""' 'interp_method="\"$interp_method\""' 'grid_dir="\"$work_dir/Regrid_Maps/\""'  'srcPath="\"$data_dir/\""' 'dstPath="\"$interp_dir/\""' 'nx=$nlon' 'ny=$nlat' < $my_ncl_dir/interp_se_to_latlon.ncl" > $work_dir/$case.regrid.sh
      source $work_dir/$case.regrid.sh > $work_dir/$case.regrid.sh.output
      if (-e abnormal_ext) then
        echo "ncl script was not successful: "$work_dir/$case.regrid.sh
        echo "see output from ncl script   : "$work_dir/$case.regrid.sh.output
        echo "ABORTING SCRIPT"
        exit
      endif
    endif
  end
end
unset n
unset case
unset n 
unset hn 
unset root 
unset data_dir 
unset interp_dir
unset work_dir
unset plot_dir
