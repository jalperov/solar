## extract each tmp forecast horizon a single predictor
## open netCDF file
local({pkg <- select.list(sort(.packages(all.available = TRUE)),graphics=TRUE)
if(nchar(pkg)) library(pkg, character.only=TRUE)})
path<-"C:\\Users\\jalperov\\temp\\gefs_train\\train\\"
files_train<-list.files(path=path,pattern=glob2rx("tmp_*.nc$"),full.names=T)


for(i in 1:length(files_train)) {
   nc2<-nc_open(files_train[i])     

## Load the default variable
   ncvar<-ncvar_get(nc2)
## permute columns to simply handling
   ncvar_perm<-aperm(ncvar,c(1,2,3,5,4))
## Compute min/mean/max over the 11 runs
## First create the array
   ncvar_pred<-array(,dim=c(dim(ncvar_perm)[1:4],3))
# Then compute values
   ncvar_pred[,,,,1]<-apply(ncvar_perm,1:4,min)
   ncvar_pred[,,,,2]<-rowMeans(ncvar_perm,dims=4)
   ncvar_pred[,,,,3]<-apply(ncvar_perm,1:4,max)
   print(c(files_train[i],ncvar_pred[1,1,1:5,1,1:3]))
# Finaly save everything
  save(ncvar_pred,file=paste0(files_train[i],".RData"),precheck=FALSE)
  nc_close(nc2)
  rm(nc2,ncvar,ncvar_perm,ncvar_sum,ncvar_pred)
}
