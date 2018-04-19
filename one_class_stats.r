library(diptest)
library(nortest)
library(moments)
#library(bimodalitytest)

analyse_class <- function(filename){
	dat = read.csv(filename, header=FALSE, skip=1)
	x = dat$V1

	dip_res = dip.test(x)
	shapiro_res = shapiro.test(x)
	ad_res = ad.test(x)

    #bimt = bimodality.test(x)

	results = numeric()
	results[1] = length(x)
	results[2] = mean(x)
	results[3] = sd(x)
	results[4] = kurtosis(x)
	results[5] = skewness(x)
	results[6] = dip_res[1]
	results[7] = dip_res[2]
	results[8] = shapiro_res[1]
	results[9] = shapiro_res[2]
	results[10] = ad_res[1]
	results[11] = ad_res[2]
    results[12] = 0#bimt@p_value
    results[13] = 0#bimt@LR

    ldat = log(dat)
    #print(ldat)
    lx = ldat$V1
    shapiro_lres = shapiro.test(lx)
    results[14] = shapiro_lres[1]
    results[15] = shapiro_lres[2]

    print(results)
	return(results)
}

args <- commandArgs(trailingOnly = TRUE)

filestance = args[1]#"grades_2012w_4.csv"
filename = paste(filestance,sep="/")
sink = paste("r_output",filestance,sep="/")

res = analyse_class(filename)
res = t(res)

#save(res, file = sink, ascii=TRUE)
write.table(res, file = sink, sep=",", eol="\n", row.names=FALSE, col.names=FALSE) 

