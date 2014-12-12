; FILE: prect_hov.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
yr1 = getenv("FIRSTYR")
yr2 = getenv("LASTYR")
rgb = getenv("RGB")

;firstyr = stringtointeger(yr1)
;lastyr = stringtointeger(yr2)

f = addfile(filename,"r")
;f = addfile("NE30NP4_APE.prect.nc.bilinear_to_0.9x1.25.nc","r")


anom = f->PRECT
anom_eq = dim_avg_Wrap(anom(time|:,lon|:,{lat|-5:5}))
anom_eq = 1000*24*3600*anom_eq

wks = gsn_open_wks("pdf",plotName)
cmap = "BlGrYeOrReVi200"
gsn_define_colormap(wks,cmap)

minlon = 0.0
maxlon = 360.0

plot = new(1,graphic)
res = True
res@gsnMaximize = True
res@gsnPaperOrientation = "portrait"
res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False
;res@lbOrientation = "vertical"
res@lbBoxMinorExtentF = 0.18
res@trYReverse = True
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/2,4,6,8,10,12,14,16,18,20,22,26,34,82/)
res@txFontHeightF = 0.018
res@tmYLLabelFontHeightF = 0.015
res@tmXBLabelFontHeightF = 0.015
res@tmYLMode = "Manual"
;res@tmYLTickStartF = firstyr
;res@tmYLTickEndF = lastyr+1
res@tmYLTickSpacingF = 1.0
res@tmYLMinorPerMajor = 3
res@tiYAxisString = "Time"
res@tiYAxisFontHeightF = 0.018
res@tiXAxisString = "Longitude"
res@tiXAxisFontHeightF = 0.018
res@tmYUseLeft = True
;res@tmXBMode = "Manual"
;res@tmXBTickStartF = minlon 
;res@tmXBTickEndF = maxlon
;res@tmXBTickSpacingF = 20.0
;res@tmXBMinorPerMajor = 3
;res@tiXAxisFontHeightF = 0.015
;res@vpWidthF = 0.50
;res@vpHeightF = 0.95
;res@tiMainString = casename+" Monthly Precipitation Rate Anomalies"
res@tiMainFontHeightF = 0.022
res@gsnLeftString = "5S-5N"
res@gsnRightString = "mm/day"
res@tiMainString = "PRECT ("+case+")"
;res@tiMainString = "PRECT for CAM4-SE APE simulation (NE30NP4)"
plot = gsn_csm_hov(wks,anom_eq(:,:),res)

end
