library(data.table)
library(ReX)

# load rearranged matrix with all subs and runs
df <- fread('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/rearranged_matrix.csv')

# set constants
n_perms <- 1000
conds <- c("M", "R")

# extract data from df
data <- as.matrix(df[,5:dim(df)[2]])

# create distance matrix with all subjects and runs
Dmax <- dist(data, method = "euclidian")

# 
