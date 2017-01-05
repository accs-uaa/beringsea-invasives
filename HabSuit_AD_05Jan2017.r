##Habitat suitability
#create binary suitability map for each species based on temp/sal tolerance

##start up requirements
require(dplyr)
require(lattice)
##Lattice set up
panel.mean <- function(x, y, ...) {
	cat('Mean', fill =T)
    tmp <- tapply(x, y, FUN = mean); print(tmp)
    panel.points(x=tmp, y=seq_along(tmp), ...)
}
cexFactor = 1

#read files
SpToler<-read.csv(file.path(baseDir, 'taxaData/Species_Tolerances.csv'))
##models
ff<-list.files(path = file.path(baseDir, 'rData')) 

###still need to loop all of this...
MAX<-F #set to T if want max temp instead of mean...

for(i in 1:ff[c(3,4)]){ ##load only hindcast sal and temp  
	f = ff[i] 
	cat('=== Handling ===', f, fill =T) 
	load(file.path(baseDir, 'rData', f))
	ddPrimeWeeks<-tbl_df(sgdf.Max@data[, substring(names(sgdf.Max@data), 6,7) %in% as.character(20:40)]) ##sets weeks of interest 20-40
	sgdf_PW<-sgdf.Max ##creating prime week subset
	
	if(MAX){
		ddPW_max <- data.frame(meanPW = apply(ddPrimeWeeks, 1, max, na.rm=TRUE)) ## Take the max across the prime weeks.
		sgdf_PW@data <- ddPW_max	
	}else{
		ddPW_mean <- data.frame(meanPW = apply(ddPrimeWeeks, 1, mean, na.rm=TRUE)) ## Take the mean across the prime weeks.
		sgdf_PW@data <- ddPW_mean
	}
	PW.sal<-raster(sgdf_PW) ##how to have for loop name files differently...
}
plot(PW.temp)
plot(PW.sal)


##working on it...	
for (i in 1:length(SpToler$Sci_Name)){ 
	##define tolerances
	lowT<-SpToler$Min_TempC[i]
	highT<-SpToler$Max_TempC[i]
	lowS<-SpToler$Min_Salinity[i]
	highS<-SpToler$Max_Salinity[i]
	
	##reclassify sal & temp rasters into binary
	thresT <- c(-Inf, lowT, 0,  lowT, highT, 1,  highT, Inf, 0)
	Tmat <- matrix(thresT, ncol=3, byrow=TRUE)
	rastTemp <- reclassify(PW.temp, Tmat)
	thresS <- c(-Inf, lowS, 0,  lowS, highS, 1,  highS, Inf, 0)
	Smat <- matrix(thresS, ncol=3, byrow=TRUE)
	rastSal <- reclassify(PW.sal, Smat)
	
	#combine
	combRast<-rastTemp*rastSal
	print(combRast) ##check max/mins?
	##plot results
	plotName <- paste0(paste0(unlist(strsplit(as.character(SpToler$Sci_Name[i])," ")),collapse = "_"),'.png')
	plotTitle <- paste0('Suitability for ', SpToler$Sci_Name[i])
	png(filename = file.path(file.path(baseDir, 'plots/TaxaSuitability', plotName)), width = plotResX , height = plotResY)
	plot(combRast,main=plotTitle,breaks=c(0,0.5,1),col=c("lavender","goldenrod1"),ext=e)
	
}


rm(lowT,highT,thresT,Tmat,thresS,Smat,rastSal,combRast)




################################		
############JUNK################
################################
##try using reclassify
# all values >= 0 and <= 0.25 become 1, etc.
threshold <- c(-Inf, low, 0,  low, high, 1,  high, Inf, 0)
tmat <- matrix(threshold, ncol=3, byrow=TRUE)
Toler.rast <- reclassify(PW.r, tmat)
plot(Toler.rast)
##raster calc
low<-11
high<-16
PW.r[PW.r > low&PW.r < high] <- 0 ##something doesn't work because less is shown if low is lower
PW.r[PW.r > 0] <- 1
plot(PW.r)
