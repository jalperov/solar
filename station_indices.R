# Compute the closest i,j indices wrt a given station
station_file<-"C:\\Users\\jalperov\\temp\\station_info.csv"
START_LAT<-31
START_LON<-254
stations<-read.csv(station_file)
stations$nlat<-round(stations$nlat)
stations$elon<-round(stations$elon)+360
stations_indices<-array(,dim=c(dim(stations)[1],2))
stations_indices[,1]<-stations$nlat-START_LAT+1
stations_indices[,2]<-stations$elon-START_LON+1
save(stations_indices,file="C:\\Users\\jalperov\\temp\\station_indices.RData",precheck=FALSE)
