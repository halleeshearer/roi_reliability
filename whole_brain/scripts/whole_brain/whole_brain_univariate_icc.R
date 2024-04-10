# load packages
library(data.table)
library(ReX)
library(tidyverse)

# load the whole-brain rearranged matrix data
matrix <- fread('/home/hallee/scratch/hcp/reliability/rearranged_matrices/rearranged_matrix.csv')

# remove first column (new_row)
data <- matrix[,2:dim(matrix)[2]]

# for each condition...
conditions <- c("M", "R")

start.time <- Sys.time()

for (cond in conditions) {
  this_cond <- data[data[[2]]==cond,]
  data <- as.matrix(this_cond[,4:dim(this_cond)[2]])
  subID <- as.matrix(this_cond[,1])
  session <- as.matrix(this_cond[,3])

  # calculate univariate ICC:
  df_icc <- data.frame(lme_ICC_2wayR(data, subID, session))

  # save results
  write.csv(df_icc, file = paste0('/home/hallee/scratch/hcp/reliability/', cond, '_whole-brain_ICC.csv'))
}
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  time.taken


