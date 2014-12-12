#!/bin/tcsh
setenv data_dir    "/Users/pel/Documents/publications/journal/2015-MWR-physgrid/new-ullrich-interp/data"
setenv work_dir    "/Users/pel/Documents/publications/journal/2015-MWR-physgrid/new-ullrich-interp/work"
setenv interp_dir  "/Users/pel/Documents/publications/journal/2015-MWR-physgrid/new-ullrich-interp/work/latlon/"
setenv my_ncl_dir  "/Users/pel/Documents/ncl_scripts"
setenv plot_dir    "/Users/pel/Documents/publications/journal/2015-MWR-physgrid/new-ullrich-interp/plots"
#setenv data_dir    "/glade/scratch/pel/new_ape/final"
#setenv my_ncl_dir  "/glade/u/home/pel/ncl_scripts"
#setenv work_dir    "/glade/scratch/pel/new_ape/final/new_analysis/work"
#setenv plot_dir    "/glade/scratch/pel/new_ape/final/new_analysis/plots"
#setenv pdf_dir    "/glade/scratch/pel/new_ape/final/new_analysis/pdf-data"

setenv nlon  360
setenv nlat  180
setenv avetime "30-months"
#setenv computePDF_PRECT 0  #do not compute PDF
setenv computePDF_PRECT 1   #compute PDF

#setenv interpfile  {$avefile}.patch_to_nlon{$nlon}xnlat{$nlat}.nc

set cases = ( "NE30NP4_APE" "NE30NP4NC2_APE" "NE30NP4NC3_APE" "NE30NP4NC4_APE" )
set line_colors = "(/"\"red\"","\"blue\"","\"sienna1\"","\"deepskyblue\""/)"
#setenv all_cases_ncl_string  "(/"\"NE30NP4_APE\"","\"NE30NP4NC2_APE\"","\"NE30NP4NC3_APE\"","\"NE30NP4NC4_APE\""/)"
#
# code this so that these strings are coded automatically
#
setenv all_cases_ncl_string  "(/"\"$cases[1]\"","\"$cases[2]\"","\"$cases[3]\"","\"$cases[4]\""/)"
setenv all_cases_ncl_files  "(/"\"$interp_dir/$cases[1].ave.$avetime.nc.patch_to_nlon{$nlon}xnlat{$nlat}.nc\"","\"$interp_dir/$cases[2].ave.$avetime.nc.patch_to_nlon{$nlon}xnlat{$nlat}.nc\"","\"$interp_dir/$cases[3].ave.$avetime.nc.patch_to_nlon{$nlon}xnlat{$nlat}.nc\"","\"$interp_dir/$cases[4].ave.$avetime.nc.patch_to_nlon{$nlon}xnlat{$nlat}.nc\""/)"

echo $all_cases_ncl_files

#
# DO NOT EDIT BELOW
#
if (! -e $plot_dir) then
  mkdir $plot_dir
endif
if (! -e $work_dir) then
  mkdir $work_dir
endif
if (! -e $interp_dir) then
  mkdir $interp_dir
endif
#setenv all_cases_ncl_list  "(/"\"""
#foreach case (NE30NP4_APE NE30NP4NC2_APE NE30NP4NC3_APE NE30NP4NC4_APE)
foreach case ($cases)
  if (-e abnormal_ext) then
    rm abnormal_ext
  endif
  #*********************************************
  #
  # average data
  #
  #*********************************************
  setenv avefile {$case}.ave.$avetime.nc
  if (-e $data_dir/$avefile) then
     echo "Skipping making $avefile (file already exists)"
  else
    echo "Making "$avefile
    setenv files  `ls $data_dir/$case/*.h0.0000-06.nc $data_dir/$case/*.h0.0000-07.nc $data_dir/$case/*.h0.0000-08.nc $data_dir/$case/*.h0.0000-09.nc $data_dir/$case/*.h0.0000-10.nc $data_dir/$case/*.h0.0000-11.nc $data_dir/$case/*.h0.0000-12.nc $data_dir/$case/*.h0.0001-*.nc $data_dir/$case/*.h0.0002-01.nc $data_dir/$case/*.h0.0002-02.nc $data_dir/$case/*.h0.0002-03.nc $data_dir/$case/*.h0.0002-04.nc $data_dir/$case/*.h0.0002-05.nc $data_dir/$case/*.h0.0002-06.nc`
    ncra $files $data_dir/$avefile
  endif
  #*********************************************
  #
  # interpolate to lat-lon
  #
  #*********************************************
  setenv interpfile  {$avefile}.patch_to_nlon{$nlon}xnlat{$nlat}.nc

#  setenv all_cases_ncl_list  "$all_cases_ncl_list""$data_dir/$interpfile"""\"","\"""
  if (-e $data_dir/$interpfile) then
    echo "Skipping interpolating $avefile ($interpfile exists)"
  else
    echo "Creating "$interpfile
    if (! -e $work_dir/Regrid_Maps) then
       mkdir $work_dir/Regrid_Maps
    endif
    if (-e $work_dir/$case.regrid.sh) rm $work_dir/$case.regrid.sh
    if (-e $work_dir/$case.regrid.sh.output) rm $work_dir/$case.regrid.sh.output
    echo "ncl  'case="\"$avefile\""' 'ingrid="\"$case\""' 'outgrid="\"nlon{$nlon}xnlat{$nlat}\""' 'interp_method="\"patch\""' 'grid_dir="\"$work_dir/Regrid_Maps/\""'  'srcPath="\"$data_dir/\""' 'dstPath="\"$interp_dir/\""' 'nx=$nlon' 'ny=$nlat' < $my_ncl_dir/interp_se_to_latlon.ncl" > $work_dir/$case.regrid.sh
    source $work_dir/$case.regrid.sh > $work_dir/$case.regrid.sh.output
    if (-e abnormal_ext) then
      echo "ncl script was not successful: "$work_dir/$case.regrid.sh
      echo "see output from ncl script   : "$work_dir/$case.regrid.sh.output
      echo "ABORTING SCRIPT"
      exit
    endif
  endif
end
  #*********************************************
  #
  # zonal-time average plots
  #
  #*********************************************
foreach var (PS PRECT CLDTOT CLOUD Q T OMEGA U RELHUM V PTEQ PTTEND ALBEDO)
  setenv vname $var
  if (-e $plot_dir/zonal_time_avg_{$vname}.pdf || -e $plot_dir/2d_{$vname}.pdf) then
    echo "plot already exists (skipping) "$plot_dir/zonal_time_avg_{$vname}.pdf
  else
    echo "doing zonal_time_avg plot for "$vname
    setenv ncl_script  $work_dir/zonal_time_avg_{$vname}.sh  
    if (-e $ncl_script) then
      rm $ncl_script
      rm $ncl_script.output
    endif
    echo "ncl 'vname="\"$vname\""' 'vertical_height = "False"' 'case="$all_cases_ncl_string"' 'lsArg="$all_cases_ncl_files"'  'plot_dir="\"$plot_dir\""' 'plot_lat_section="True"' 'plot_lat_section_min=0' 'plot_lat_section_max=80' 'coslat="False"' 'diff="True"' 'line_colors="$line_colors"' 'lsinx = "True"' < $my_ncl_dir/zonal_time_avg.ncl"  > $ncl_script
    source $ncl_script > $ncl_script.output
    if (-e abnormal_exit_zonal_time_avg) then
      echo "ncl script was not successful: " $ncl_script
      echo "see output from ncl script   : " $ncl_script.output
      echo "ABORTING SCRIPT"
      exit
    endif
    mv $plot_dir/zonal_time_avg_{$vname}.pdf $plot_dir/zonal_time_avg_{$vname}.pdf.tmp
    pdfcrop $plot_dir/zonal_time_avg_{$vname}.pdf.tmp $plot_dir/zonal_time_avg_{$vname}.pdf
    rm $plot_dir/zonal_time_avg_{$vname}.pdf.tmp
  endif
end


#foreach file ($plot_dir/*.pdf)
#  mv $file $file.tmp
#  pdfcrop $file.tmp $file
#  rm $file.tmp
#end


if ($computePDF_PRECT == 1) then
  echo "   "
  echo "PDF PDF PDF ---------------------------------------"
 
  foreach case ($cases)
#data_dir/$case/
    echo "case"$case
    unset files
    setenv files  `ls $data_dir/$case/*.h2.0000-06-*.nc $data_dir/$case/*.h2.0000-07-*.nc $data_dir/$case/*.h2.0000-08-*.nc $data_dir/$case/*.h2.0000-09-*.nc $data_dir/$case/*.h2.0000-10-*.nc $data_dir/$case/*.h2.0000-11-*.nc $data_dir/$case/*.h2.0000-12-*.nc $data_dir/$case/*.h2.0001-*.nc $data_dir/$case/*.h2.0002-01-*.nc $data_dir/$case/*.h2.0002-02-*.nc $data_dir/$case/*.h2.0002-03-*.nc $data_dir/$case/*.h2.0002-04-*.nc $data_dir/$case/*.h2.0002-05-*.nc $data_dir/$case/*.h2.0002-06-*.nc`
    setenv work_dir_prect $work_dir/PRECT_data
    if (! -e $work_dir_prect) then
      mkdir $work_dir_prect
    endif

#
# WARNING: if you rerun this you will interpolate already interpolated files ....
#

# if (1==1) then
    foreach file ($files)
      unset interpfile
      setenv interpfile  {$file}.patch_to_nlon{$nlon}xnlat{$nlat}.nc
      if (-e $interpfile) then
        echo "Skipping interpolating ($interpfile exists)"
      else
        echo "Interpolating file "$file
        if (! -e $work_dir/Regrid_Maps) then
           mkdir $work_dir/Regrid_Maps
        endif
        if (-e $work_dir_prect/$case.regrid.sh) rm $work_dir_prect/$case.regrid.sh
        echo "ncl  'lsArg="\"$file\""' 'ingrid="\"$case\""' 'outgrid="\"nlon{$nlon}xnlat{$nlat}\""' 'interp_method="\"patch\""' 'grid_dir="\"$work_dir/Regrid_Maps/\""'  'srcPath="\"/\""' 'dstPath="\"$work_dir_prect\""' 'nx=$nlon' 'ny=$nlat' < $my_ncl_dir/interp_se_to_latlon.ncl" > $work_dir_prect/$case.regrid.sh
        source $work_dir_prect/$case.regrid.sh > $work_dir_prect/$case.regrid.sh.output
        if (-e abnormal_ext) then
          echo "ncl script was not successful: "$work_dir_prect/$case.regrid.sh
          echo "see output from ncl script   : "$work_dir_prect/$case.regrid.sh.output
          echo "ABORTING SCRIPT"
          exit
        endif
        rm $work_dir_prect/$case.regrid.sh
        rm $work_dir_prect/$case.regrid.sh.output
     endif
    end
# endif
   #
   # PDF computation
   #
    if (-e $work_dir_prect/$case.pdf.sh) rm $work_dir_prect/$case.pdf.sh 
    if (-e $work_dir_prect/$case.pdf.sh.output) rm $work_dir_prect/$case.pdf.sh.output
    echo "computing PDF for "$case
    if (! -e $pdf_dir) then
      mkdir $pdf_dir
    endif
    echo "ncl  'vname="\"PRECT\""' 'dir="\"$data_dir/$case/\""' 'pdf_data_dir="\"$pdf_dir\""' 'case_in="\"$case\""' 'lsArg="\"\*h2\*.nc.\*patch_to_nlon{$nlon}xnlat{$nlat}.nc\""' < $my_ncl_dir/prec_pdf_latlon.ncl" > $work_dir_prect/$case.pdf.sh
    source $work_dir_prect/$case.pdf.sh > $work_dir_prect/$case.pdf.sh.output
    echo $work_dir_prect/$case.pdf.sh
  end
endif 


#
