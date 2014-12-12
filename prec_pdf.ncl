load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  ;
  ; check if output data file exists
  ;
  fout_name = pdf_data_dir+"/pdf_"+vname+"_"+case_in+".nc"
  if (isfilepresent(fout_name)) then
    print("Removing file "+fout_name)
    system("rm "+fout_name)
  end if

 ; files =  systemfunc("ls "+dir+lsArg)
  files =  systemfunc("ls /glade/scratch/pel/new_ape/final/NE30NP4_APE/NE30NP4_APE.cam.h2.0000-06-07-43200.nc.patch_to_nlon120xnlat60.nc")
  f  = addfiles (files,"r")
  ListSetType(f,"cat") 
  print(f)


  lat=f[0]->lat

  prect = f[:]->$vname$
  printVarSummary (prect)
  prect  = prect*3600*24*1000
  prect@units = "mm/day"
  ;
  ; create bins
  ;
  nbins=4000
  bin1 = new ( (/nbins/), "double")
  bin1 = 0

  x1 = new ( (/nbins/), "double")
  x1(0)=0        
  do i=1,nbins-1
    x1(i)=i-0.5
  end do

  nsteps = dimsizes(prect(:,0))
  ncol = (dimsizes(f[0]->area))

  totn = sum(where( abs(f[0]->lat) .le. 10.0 , 1, 0))
  bandarea = sum(where( abs(f[0]->lat) .le. 10.0 , f[0]->area, 0.0))
  totarea = sum(f[0]->area)
  print("+/- 10 degree equatorial band: n="+totn+" area="+bandarea+" total area="+totarea) 
  bin_tmp = bin1  ; create bin_tmp      
  bin_tmp = 0
  times = f[:]->time        
  nrecords = 0
  do t=0,nsteps-1
    prect1  = doubletoint(prect(t,:) + .999999);
    print("min/max prect: "+min(prect1)+" "+max(prect1)+" t="+times(t))

    ; give all values outside 10 degree band a 0 weight
    aband = where( abs(f[0]->lat) .le. 10.0 , f[0]->area/bandarea, 0.0)

    ;   much faster, but produces wrong results, because of indicies appear
    ;   more than once in prect1()
    ;   bin1(prect1(:)) = bin1(prect1(:)) + aband(:)
    do i=0,ncol-1
      bin_tmp(prect1(i)) = bin_tmp(prect1(i)) + aband(i)
    end do
    nrecords = nrecords + 1
  end do
  bin1 = bin1 + bin_tmp
 

  bin1=bin1/nrecords
  bin1 = where( bin1.eq.0, bin1@_FillValue, bin1 )
  print("sum bin1 = "+sum(bin1)+"  nrecords="+nrecords)


  fout  = addfile(fout_name,"c")
  fout->pdf=bin1
  fout->x=x1




;  nbin  = 600
;  pdf_prec = new ( (/nbin/), double)
;  bins      = new ( (/nbin/), double)
;  opt          = True
;  opt@bin_min  = 0. 
;  opt@bin_max  = 600.
; 
;  print(dimsizes(prect))
;
;  prect = where(lat.le.5.0,prect,0.)
;
;  pdf    = pdfx(prect, nbin, opt)
;
;  bins  = pdf@bin_center
;
;
;  pdf = where(pdf .eq. 0., 1.e-10, pdf)
;
;  print(pdf)
;




;******************************************************
; create plot
;******************************************************
  wks = gsn_open_wks("eps","pdf_prec")               ; open workstation
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
  plot = new(1,graphic)
print("start plotting")
  res                      = True         ; plot modifications desired
  res@gsnDraw              = True        ; don't draw plot
  res@gsnFrame             = True       ; don't advance frame

  ;res@tiMainString        = "Total Precipitation" 
  res@xyDashPatterns          = (/1,0,1,0,1,0,1,0/)  
  res@xyLineColors       = (/"sienna1","sienna1","red","red","deepskyblue","deepskyblue","blue","blue"/)
  res@xyLineThicknesses  = (/4.0,4.0,4.0,4.0,4.0,4.0,4.0,4.0/)
  res@xyExplicitLegendLabels = (/"ne120_SOM Convection","ne120_SOM Total","ne120 Convection","ne120 Total","ne30_SOM Convection","ne30_SOM Total","ne30 Convection","ne30 Total"/)
  res@tiXAxisString          = "Precipitation (mm/day)"
  res@tiYAxisString          = "Probability"
  res@pmLegendDisplayMode    = "Always"                      ; turn on legend
  res@pmLegendSide           = "Bottom"                      ; Change location of
  res@pmLegendParallelPosF   = .65                           ; move units right
  res@pmLegendOrthogonalPosF = -1.15                          ; move units down
  res@pmLegendWidthF         = 0.14                          ; Change width and
  res@pmLegendHeightF        = 0.21                           ; height of legend.
  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .02                          ; label font height
  res@trYMaxF                = 1.0
  res@trYMinF                = 1e-7 
  res@trXMinF                = 1.0
  res@trXMaxF                = 600.0
  res@xyYStyle          = "Log"
;  res@xyXStyle          = "Log"
  res@tmYLMajorOutwardLengthF = 0
  res@tmXBMajorOutwardLengthF = 0
  res@tmYLMinorOutwardLengthF = 0
  res@tmXBMinorOutwardLengthF = 0
  res@gsnXYBarChart            = True              ; Create bar plot
  res@gsnXYBarChartOutlineOnly = True

print("here")
;  plot(0)   = gsn_csm_xy(wks,bins,pdf/100.,res)
  plot(0)   = gsn_csm_xy(wks,x1,bin1,res)
;  plot(0)   = gsn_xy(wks,bins(0,:),pdf_prec(0,:)/100.,res)

print("here final") 

end

