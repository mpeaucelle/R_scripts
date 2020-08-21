# Author: Marc Peaucelle, 2020
# This script creates an empty netcdf file based on an existing template
# Basically it copies dimensions, variables and attributes 
# Used to aggregate ISIMIP IPSL 1deg climate data to the 2deg CRUJRA resolution

library(RNetCDF)

# template files
template1<-"./METEO/CRUJRA/v2.1/twodeg/crujra_twodeg_v2.1_2019.nc"
template<-"./METEO/ISIMIP2B/ipsl_rcp85_onedeg/IPSL-CM5A-LR_rcp85_onedeg_daily_2019.nc"

# output names
templateName<-"IPSL_rcp85"
fileout<-"IPSL_twodeg_template.nc"

# open and copy netcdf
incdf1<-open.nc(template1)
incdf<-open.nc(template)

# summarizes nc file
cdfsum<-file.inq.nc(incdf)

# create new file
nc <- create.nc(fileout)

# add dimensions from IPSL
#for (i in 0:(cdfsum$ndims-1)){
#    tempdim<-dim.inq.nc(incdf,i)
#    dim.def.nc(nc, dimname=tempdim$name,dimlength=tempdim$length,unlim=tempdim$unlim)
#    rm(tempdim)
#}

# or add dimensions from CRUJRA
dim.def.nc(nc,dimname="longitude",dimlength=180,unlim=FALSE)
dim.def.nc(nc,dimname="latitude",dimlength=90,unlim=FALSE)
dim.def.nc(nc,dimname="tstep",dimlength=365,unlim=TRUE)

# add variables
for (i in 0:(cdfsum$nvars-1)){
    tempvar<-var.inq.nc(incdf,i)
    var.def.nc(nc, varname=tempvar$name,vartype=tempvar$type,dimensions=tempvar$dimids)
    rm(tempvar)
}

# copy attributes variables
for (i in 0:(cdfsum$nvars-1)){
    tempvar<-var.inq.nc(incdf,i)
    for (j in 0:(tempvar$natts-1)){
        att.copy.nc(ncfile.in=incdf,variable.in=i,attribute=j,ncfile.out=nc,variable.out=i)
    }
    rm(tempvar)
}


# copy time, continental fraction and navigation variables
# only meteo data will be aggregated
var.put.nc(ncfile=nc,variable="nav_lat",data=var.get.nc(incdf1,"nav_lat"))
var.put.nc(ncfile=nc,variable="nav_lon",data=var.get.nc(incdf1,"nav_lon"))
var.put.nc(ncfile=nc,variable="contfrac",data=var.get.nc(incdf1,"contfrac"))
var.put.nc(ncfile=nc,variable="time",data=var.get.nc(incdf,"time"))
var.put.nc(ncfile=nc,variable="tstep",data=var.get.nc(incdf,"tstep"))
var.put.nc(ncfile=nc,variable="timestp",data=var.get.nc(incdf,"timestp"))

# add global attributes (optional)
att.put.nc(ncfile=nc,variable="NC_GLOBAL",name="description",type="NC_CHAR",value=paste0("Clone of ",templateName))
att.put.nc(ncfile=nc,variable="NC_GLOBAL",name="history",type="NC_CHAR",value=paste0("Created on ",date()))

sync.nc(nc)
close.nc(nc)




