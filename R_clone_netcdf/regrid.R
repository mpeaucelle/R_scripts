# Author: Marc Peaucelle, 2020
# This script is used to aggregate ISIMIP IPSL 1deg climate data to the 2deg CRUJRA resolution
# First, create a template by calling 'clone_cdf.R'

library(RNetCDF)
library(raster)

# define working paths
pathin<-"./METEO/ISIMIP2B/ipsl_rcp85_onedeg/"
pathout<-"./tmp_rcp85/"
templatepath<-"./IPSL_twodeg_template.nc" # Created with 'clone_cdf.R'

# List all years to regrid
ficlist<-list.files(pathin)

# List variables to regrid
vari<-c("Tmin","Tmax","PSurf","Qair","Wind","precip","SWdown","LWdown")
#Tair need to be calculated, not included in IPSL

for (i in ficlist){
  # Loop over files
  print(i)
  incdf<-open.nc(paste0(pathin,i))
  # Create new netcdf
  fileout<-paste0("IPSL_RCP85_twodeg_",substr(i,33,36),".nc")
  system(paste0("cp ",templatepath," ",pathout,fileout))
  
  outcdf<-open.nc(paste0(pathout,fileout),write=TRUE)
  for(j in vari){
    # Loop over variables
    print(j)
    tempvar<-var.get.nc(incdf,j)
    tempvar<-aperm(tempvar,c(2,1,3)) 
    rtemp<-brick(tempvar,xmn=-180,xmx=180,ymn=-90,ymx=90)
    # aggregate from 1deg to 2deg spatial resolution
    rtemp2<-aggregate(rtemp,fact=2,fun=mean)
    tempvar<-aperm(as.array(rtemp2),c(2,1,3))
    # Add values to the new netcdf
    var.put.nc(ncfile=outcdf,variable=j,data=tempvar)
  }
  # Special treatments for continental areas that have to be summed and not averaged
  tempvar<-var.get.nc(incdf,"Areas")
  tempvar<-t(tempvar)
  rtemp<-raster(tempvar,xmn=-180,xmx=180,ymn=-90,ymx=90)
  rtemp2<-aggregate(rtemp,fact=2,fun=sum)
  tempvar<-t(as.matrix(rtemp2))
  var.put.nc(ncfile=outcdf,variable="Areas",data=tempvar)
  
  # Add global attributes (optional)
  att.put.nc(ncfile=outcdf,variable="NC_GLOBAL",name="title",type="NC_CHAR",value=paste0(fileout))
  att.put.nc(ncfile=outcdf,variable="NC_GLOBAL",name="description",type="NC_CHAR",value=paste0("Clone of ",templateName))
  att.put.nc(ncfile=outcdf,variable="NC_GLOBAL",name="history",type="NC_CHAR",value=paste0("Created on ",date()))
  
  sync.nc(outcdf)
  close.nc(outcdf) 
}




