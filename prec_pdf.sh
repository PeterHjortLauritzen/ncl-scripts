#
# user defined environment settings
#
#
# location of NCL script
#
#setenv my_ncl_dir "/Users/pel/Documents/ncl_scripts/" 
setenv my_ncl_dir "/glade/u/home/pel/ncl_scripts/"
echo "directory for ncl scripts: " $my_ncl_dir
#
# directory of source data
#
setenv sourceDataDir "/glade/scratch/pel/new_ape/"
echo "source data path: " $sourceDataDir

setenv case "NE30NP4_APE"

setenv dir $sourceDataDir$case/
echo "Dir: " $dir
#
# lsArg: NCL script will interpolate/remap files that match ls lsArg
#
# interp_method can be "billienar", "conserve", "patch" 
#
rm tmp.ncl
echo "ncl  'vname="\"PRECT\""' 'dir="\"$dir\""' 'case_in="\"$case\""' 'lsArg="\"/\*h2\*.nc\""' < $my_ncl_dir/prec_pdf.ncl" > tmp.ncl
#echo "ncl  'vname="\"PRECT\""' 'dir="\"$dir\""' 'case_in="\"$case\""' 'lsArg="\"/NE30NP4_APE.cam.h2.0002-05-21-00000.nc\""' < $my_ncl_dir/prec_pdf.ncl" > tmp.ncl

chmod +x tmp.ncl
./tmp.ncl

#rm tmp2.ncl
#echo "ncl 'vname="\"PRECT\""' 'dir="\"./\""' 'case_in="\"$case\""' 'lsArg="\"/pdf_\*.nc\""' < $my_ncl_dir/prec_pdf_plo#t.ncl" > tmp2.ncl
#chmod +x tmp2.ncl
#./tmp2.ncl
echo "Done"