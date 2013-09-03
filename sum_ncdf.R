## open netCDF file
local({pkg <- select.list(sort(.packages(all.available = TRUE)),graphics=TRUE)
if(nchar(pkg)) library(pkg, character.only=TRUE)})
path<-"C:\\Users\\jalperov\\temp\\gefs_train\\train\\"
files_train<-list.files(path=path,pattern="*.nc$",full.names=T)


for(i in 1:length(files_train)) {
   nc2<-nc_open(files_train[i])     

## Load the default variable
   ncvar<-ncvar_get(nc2)
   
## Permute file to be able to sum values over the whole day (5*3 hours actually)
   ncvar_perm<-aperm(ncvar,c(1,2,5,4,3))
## Compute cumulative value
   ncvar_sum<-rowSums(ncvar_perm,dims=4)
## Compute min/mean/max of cumulative results over the 11 runs
## First create the array
   ncvar_pred<-array(,dim=c(dim(ncvar_sum)[1:3],3))
# Then compute values
   ncvar_pred[,,,1]<-apply(ncvar_sum,1:3,min)
   ncvar_pred[,,,2]<-rowMeans(ncvar_sum,dims=3)
   ncvar_pred[,,,3]<-apply(ncvar_sum,1:3,max)
   print(c(files_train[i],ncvar_pred[1,1,1,1:3]))
# Finaly save everything
  save(ncvar_pred,file=paste(files_train[i],".RData"),precheck=FALSE)
  nc_close(nc2)
  rm(nc2,ncvar,ncvar_perm,ncvar_sum,ncvar_pred)
}
