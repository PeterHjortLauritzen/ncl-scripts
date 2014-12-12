load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  f  = addfiles (files,"r")
  print(f)
  fcnt = dimsizes(files)
  print("fnames = "+files)
  print("fcnt   =  "+fcnt)

  fk    = 0
  x     = f[fk]->x
  nbins = dimsizes(x)
  print(nbins)

  bin_all = new ( (/fcnt,nbins/), "double")
  bin_all = 0

  do fk=0,fcnt-1
    print("reading: "+fk)
    bin=f[fk]->pdf
   
    ; normalize for plotting:
;    nrecords=fall[fk]->nrecords
;    bin1=bin1/nrecords
;    bin1 = where( bin1.eq.0, bin1@_FillValue, bin1 )
;    print("sum bin1 = "+sum(bin1)+"  nrecords="+nrecords)
  
    bin_all(fk,:)=bin(:)
  end do




;  pdf    = f[:]->pdf
;  bins   = f[:]->x

;  printVarSummary(pdf)

;******************************************************
; create plot
;******************************************************
  wks = gsn_open_wks("pdf",plotName)               ; open workstation
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
  plot = new(1,graphic)
print("start plotting")
  res                      = True         ; plot modifications desired
  res@gsnDraw              = True        ; don't draw plot
  res@gsnFrame             = True       ; don't advance frame

  res@tiMainString        = titleString
  res@xyDashPatterns          = (/0,0,0,0,0,0,0,0/)  
  res@xyLineColors       = (/"red","blue","sienna1","deepskyblue"/)
  res@xyLineThicknesses  = (/4.0,2.0,2.0,2.0,2.0,2.0,2.0,2.0/)
;  res@xyExplicitLegendLabels = (/"NE30NP4NC3 6h","NE30NP4NC3 3h","NE30NP4 6h","NE30NP4 3h","ne30_SOM Convection","ne30_SOM Total","ne30 Convection","ne30 Total"/)
  res@xyExplicitLegendLabels = case
  res@tiXAxisString          = "Precipitation (mm/day)"
  res@tiYAxisString          = "Fraction"
  res@pmLegendDisplayMode    = "Always"                      ; turn on legend
  res@pmLegendSide           = "Bottom"                      ; Change location of
  res@pmLegendParallelPosF   = .65                           ; move units right
  res@pmLegendOrthogonalPosF = -1.15                          ; move units down
  res@pmLegendWidthF         = 0.14                          ; Change width and
  res@pmLegendHeightF        = 0.21                           ; height of legend.
  res@lgPerimOn              = False                         ; turn off box around
  res@lgLabelFontHeightF     = .02                          ; label font height
  res@trYMaxF                = 1.0
  res@trYMinF                = 1e-8 
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
  plot(0)   = gsn_csm_xy(wks,x,bin_all,res)
;  plot(0)   = gsn_csm_xy(wks,x,bin_all,res)
;  plot(0)   = gsn_xy(wks,x,bin_all(1,:)-bin_all(0,:),res)

print("here final") 

end

