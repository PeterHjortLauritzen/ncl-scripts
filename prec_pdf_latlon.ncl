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

  files =  systemfunc("ls "+dir+lsArg)
  f  = addfiles (files,"r")
  ListSetType(f,"cat") 
  print(f)


  lat=f[0]->lat

  lat_min_idx=ind_nearest_coord (-10.0, lat, 0)
  lat_max_idx=ind_nearest_coord (10.0, lat, 0)
  print("min index "+lat_min_idx+" latitude="+lat(lat_min_idx))
  print("max index "+lat_max_idx+" latitude="+lat(lat_max_idx))

  prect = f[:]->$vname$(:,{lat_min_idx:lat_max_idx},:)
;  prect = f[:]->$vname$
  printVarSummary (prect)
  prect  = prect*3600*24*1000
  prect@units = "mm/day"
  ;
  ; create bins
  ;

  nsteps = dimsizes(prect(:,0,0))
  times = f[:]->time        
  nrecords = 0

  opt = True 
  delt_bin = 1
  max_ws = 120
  min_ws=  0 
  opt@bin_spacing = delt_bin
  opt@bin_min = min_ws
  opt@bin_max = max_ws 
  nbins = floattointeger((max_ws - min_ws)/delt_bin) 
  pdf1  = pdfx(prect(0,:,:), nbins,opt)  
  pdf1 = 0.0
;  bin1 = (/ pdf1 /)

  do t=0,nsteps-1
;  do t=0,0
;    pdf_eq = where( abs(f[0]->lat) .le. 10.0 , f[0]->area/bandarea, 0.0)
    pdf1  = pdf1+pdfx(prect(t,:,:), nbins,opt)
    print("t="+t)

;    prect1  = doubletoint(prect(t,:) + .999999);
;    aband = where( abs(f[0]->lat) .le. 10.0 , f[0]->area/bandarea, 0.0)
    nrecords = nrecords + 1
  end do
;  bin1 = bin1 + bin_tmp
; 
;
  pdf1=pdf1/nrecords
  pdf1=pdf1/100.0 ;convert to fraction
  pdf1 = where( pdf1.eq.0, pdf1@_FillValue, pdf1 )
  print("sum pdf1 = "+sum(pdf1)+"  nrecords="+nrecords)


  fout  = addfile(fout_name,"c")
  fout->pdf=pdf1
  fout->x=pdf1@bin_center




;******************************************************
; create plot
;******************************************************
  wks = gsn_open_wks("eps",pdf_data_dir+"/pdf_prec_"+case_in)               ; open workstation
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
  plot = new(1,graphic)
print("start plotting")
  res                      = True         ; plot modifications desired
  res@gsnDraw              = True        ; don't draw plot
  res@gsnFrame             = True       ; don't advance frame

  res@tiMainString        = "PDF of "+vname+" for "+case_in 
  res@xyDashPatterns          = (/1,0,1,0,1,0,1,0/)  
  res@xyLineColors       = (/"sienna1","sienna1","red","red","deepskyblue","deepskyblue","blue","blue"/)
  res@xyLineThicknesses  = (/4.0,4.0,4.0,4.0,4.0,4.0,4.0,4.0/)
;  res@xyExplicitLegendLabels = (/"ne120_SOM Convection","ne120_SOM Total","ne120 Convection","ne120 Total","ne30_SOM Convection","ne30_SOM Total","ne30 Convection","ne30 Total"/)
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
  res@trXMaxF                = 120.0
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
  plot(0)   = gsn_csm_xy(wks,pdf1@bin_center,pdf1,res)
;  plot(0)   = gsn_xy(wks,bins(0,:),pdf_prec(0,:)/100.,res)

print("here final") 
end
