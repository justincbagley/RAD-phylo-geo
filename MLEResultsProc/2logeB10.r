#!/usr/bin/env Rscript

##########################################################################################
#                          2logeB10 Rscript v1.1, August 2017                            #
#  Copyright (c)2017 Justinc C. Bagley, Virginia Commonwealth University, Richmond, VA,  #
#  USA; Universidade de Brasília, Brasília, DF, Brazil. See README and license on GitHub #
#  (http://github.com/justincbagley) for further info. Last update: August 22, 2017.     #
#  For questions, please email jcbagley@vcu.edu.                                         #
##########################################################################################

##--Load needed library, R code, or package stuff. Install package if not present.
#source("2logeB10.R", chdir = TRUE)
packages <- c("psych")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
    install.packages(setdiff(packages, rownames(installed.packages())))
}

library(psych)

############ Read data and output to file
##--Read in the data, output from STEP #1 of MLEResultsProc.sh script.
data <- read.table(file="MLE.output.txt", header=TRUE, sep="\t")

sink("2logeB10.output.txt")
cat("########################### MARGINAL-LIKELIHOOD ESTIMATES ###########################\n")
data
cat("\n \n")
sink()

############ Get marginal likelihood values and calculate 2loge B10 Bayes factors (2logeB10)
#--Raw path-sampling (PS) log-marginal likelihood estimates:
PS.vec <- data[,2]
PS.vec

##--Raw stepping-stone (SS) sampling log-marginal likelihood estimates:
SS.vec <- data[,3]
SS.vec

##--Matrix of 2loge BFs calculated from PS log-marginal likelihood estimates:
PS.2logeB10 = 2*(outer(PS.vec, PS.vec, `-`))
PS.2logeB10

##--Matrix of 2loge BFs calculated from SS log-marginal likelihood estimates:
SS.2logeB10 = 2*(outer(SS.vec, SS.vec, `-`))
SS.2logeB10

############ Summarize results and output to file
##--Use psych package function to combine the resulting matrices into a single, nice
##--output table with Bayes factors (BF) from PS MLEs below the diagonal and BFs from SS 
##--MLEs above the diagonal:
sink("2logeB10.output.txt", append=TRUE)
cat("##################################### BAYES FACTORS ######################################
Below diagonal: 2logeB10 values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: 2logeB10 values based on stepping-stone (SS) log-marginal likelihood estimates\n")
if(sum(PS.vec) == '0'){    
	BF_mat <- lowerUpper(PS.2logeB10, SS.2logeB10, diff=FALSE)
	BF_mat[lower.tri(BF_mat)] <- NA
	rownames(BF_mat) <- 1:length(PS.vec)
	colnames(BF_mat) <- 1:length(PS.vec)
	BF_mat
}
if(sum(SS.vec) == '0'){    
	BF_mat <- lowerUpper(PS.2logeB10, SS.2logeB10, diff=FALSE)
	BF_mat[upper.tri(BF_mat)] <- NA
	rownames(BF_mat) <- 1:length(PS.vec)
	colnames(BF_mat) <- 1:length(PS.vec)
	BF_mat
}
if( (sum(PS.vec) != '0') & (sum(SS.vec) != '0') ){    
	BF_mat <- lowerUpper(PS.2logeB10, SS.2logeB10, diff=FALSE)
	BF_mat
}
cat("\n \n")
sink()

##--Next, report PS MLE BFs below the diagonal and report the difference between PS- and 
##--SS-based BF matrices, placing the results in the above-the-diagonal entries. However, 
##--we only report the differences if both PS- and SS-based BFs could be calculated; otherwise,
##--we do not report the differences at all! If PS MLEs or SS MLEs were missing in the input 
##--(as is usually the case for BEAST2 MLE runs), then either PS.vec or SS.vec would be filled 
##--with zeros. If we computed differences in such a case, then we would be left with a square 
##--matrix in which the above-diagonal elements were the same as the below-diagonal elements, 
##--only with the opposite sign. Such a table would be equivalent to the Bayes factors table 
##--already written to file in the step above, and thus would be unnecessary.
if( (sum(PS.vec) != '0') & (sum(SS.vec) != '0') ){    
sink("2logeB10.output.txt", append=TRUE)
cat("################################ BAYES FACTOR DIFFERENCES ################################
Below diagonal: 2logeB10 values based on path sampling (PS) log-marginal likelihood estimates
Above diagonal: differences between PS- and SS-based BF values\n")
	BF_diff_mat <- lowerUpper(PS.2logeB10, SS.2logeB10, diff=TRUE)
	BF_diff_mat
cat("\n \n")
sink()
}

######################################### END ############################################
