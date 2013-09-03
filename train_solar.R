# Read training response
# memory.limit(size=10000)
library(randomForest)
source("~/solar/solar_inc.R")

solar_energy<-read.csv(train_file)
total_duration<-length(solar_energy$ACME)
load(station_indices_file)
DIM1<-5
DIM2<-5
DIM3<-3
# Read predictors
important_predictors<-read.csv(predictor_file,header=FALSE)
var<-dim(important_predictors)[1]
pred_files<-vector(mode="character",length=var)
for(i in 1:var) {
  pred_files[i]<-paste0(path,important_predictors[i,1],"_latlon_subset_19940101_20071231.nc.RData")
}
# Get dimensions
load(pred_files[1],verbose=TRUE)
ticks<-3650
pred_cnt<-DIM1*DIM2*DIM3
# Keep all forecast horizons for tmp
pred_cnt_tmp<-pred_cnt*5
ncol<-pred_cnt*12+pred_cnt_tmp*2
predictors<-matrix(,nrow=ticks,ncol=ncol)
start<-(total_duration-ticks+1)
stop<-total_duration
ii<-0
for(i in 1:var) {
   load(pred_files[i],verbose=TRUE)
# Fill the predictor matrix. There may be R-ier ways to do it
# but this one is at least readable
   tmp<-FALSE
   if (grepl("tmp",pred_files[i])) {
      tmp<-TRUE
   }
   if (!tmp) {
      ncvar_pred2<-aperm(ncvar_pred,c(3,1,2,4))
   }else {
      ncvar_pred2<-aperm(ncvar_pred,c(4,1,2,5,3))
   }
   jj<-1
   for(j in start:stop) {
      col<-1
      for(k in (stations_indices[1,2]-2):(stations_indices[1,2]+2)) {
          for(l in (stations_indices[1,1]-2):(stations_indices[1,1]+2)) {
              for(m in 1:DIM3) { 
# Special handling of tmp values  
                 if (!tmp) {           
                    predictors[jj,ii+col]<-ncvar_pred2[j,k,l,m]
                    col<-col+1
                 } else {
                    for(n in 1:5) {
                        predictors[jj,ii+col]<-ncvar_pred2[j,k,l,m,n]
                        col<-col+1
                    }
                 }
                 
              }
          }
      }
      jj<-jj+1
   }
   if (tmp) {
      ii<-ii+pred_cnt_tmp
   }else {
      ii<-ii+pred_cnt
   }
}
save(predictors,file=paste(path,"solar_energy_predictors_3.RData"))

RF<-randomForest(predictors,solar_energy$ACME[start:stop],ntree=ticks*10,importance=TRUE,localImp=TRUE)
save(RF,file="~/solar/RF_3.RData")
mae<-sum(abs(RF$predicted-solar_energy$ACME[start:stop]))/ticks
mae
  
