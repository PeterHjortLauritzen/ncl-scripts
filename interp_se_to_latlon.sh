#!/bin/tcsh
setenv root        "/Users/pel/Documents/publications/journal/physicsGrid/new-ullrich-interp/idealized-map-tests"
setenv data_dir    $root/data
setenv interp_dir  $root/interp-data
setenv my_ncl_dir  "/Users/pel/Documents/ncl_scripts"
setenv work_dir    $root/work
setenv plot_dir    $root/plots

setenv nlon  360
setenv nlat  180
setenv interp_method "patch" #billinear
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
set cases = ( "default" "mono" "non-consistent-non-mono" "non-mono" )
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
