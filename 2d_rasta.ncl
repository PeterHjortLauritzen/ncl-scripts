load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  vname = "PRECT"
;  fnames =  systemfunc("ls NE30NP4_APE.3yr_ave.6month_spinup.nc")
;  fnames =  systemfunc("ls NE30NP4NC3_APE.2yr_ave.3month_spinup.nc")
  fnames =  systemfunc("ls *spinup.nc")
  output_format = "eps"

  wks = gsn_open_wks(output_format,"2d_rasta_"+vname)
  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  fcnt = dimsizes(fnames)
  print(fnames)



;  pi = 3.14159265358979323846264338327
;  lat1d=lat1d*180.0/pi
;  lon1d=lon1d*180.0/pi


;******************************************************
; create plot
;******************************************************

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap


  res                     = True         ; plot modifications desired
  res@gsnMaximize         = True         ; Maximize size of plot in frame
  res@gsnSpreadColors     = True         ; Use full colormap, but start
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True         ; Turn on contour fill
;  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@cnFillMode="RasterFill"


;  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -1000.0                        ; set the minimum contour level
;  res@cnMaxLevelValF  = 6000                   ; set the maximum contour level
;  res@cnLevelSpacingF = 200.0                  ; set the interval between contours

;  res@mpMinLatF = -30.                   ; set the minimum latitude = -70.
;  res@mpMaxLatF = 30.                    ; set the maximum latitude = 70.

; res@mpMinLonF = -40.                    ; set the minimum latitude = -70.
;  res@mpMaxLonF = 40.

  plot = new(fcnt,graphic) 
  do k=0,fcnt-1
    print("plot "+k)
    lat1d = fall[k]->lat          ; Pull off lat/lon variable and
    lon1d = fall[k]->lon          ; convert both to 1D.

    var  = fall[k]->$vname$(0,:)    ; Read some data; convert to 1D.i

    res@tiMainString        = fnames(k)
    res@sfXArray            = lon1d        ; Required to tell NCL where to
    res@sfYArray            = lat1d        ; overlay data on globe.

    if (vname.eq."PRECT") then
      var = 1000*24*3600*var ;convert from m/s to mm/day  
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF  = 0.0
      res@cnMaxLevelValF  = 24.0               
      res@cnLevelSpacingF = 2.0              
      res@gsnRightString = "mm/day"
    end if

    plot(k) = gsn_csm_contour_map_ce(wks,var,res)
    delete(lon1d)
    delete(lat1d)
    delete(var)
    delete(res@sfXArray)
    delete(res@sfYArray)
  end do

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelLabelBar = True                   ; add common colorbar
;  resP@gsnPanelBottom   = 0.05
;  resP@txString   = "A common title"
  gsn_panel(wks,plot,(/1,fcnt/),resP)               ; now draw as one plot


  txres               = True
;  txres@txFontHeightF = 0.015
;  gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end
