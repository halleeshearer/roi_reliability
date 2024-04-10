library(data.table)
library(ReX)

# load rearranged matrix with all subs and runs
df <- fread('/scratch/st-tv01-1/hcp/reliability/rearranged_matrices/rearranged_matrix.csv')

# set constants
n_perms <- 1000
conds <- c("M", "R")

# extract data from df
data <- as.matrix(df[,5:dim(df)[2]])
subID <- as.matrix(rep(1:109, each = 2))
session <- as.matrix(rep(1:2, 109))


# create distance matrix with all subjects and runs
Dmax <- as.matrix(dist(data, method = "euclidian"))

# permutations
# load permuted condition labels:
perm_labels <- read.csv('/home/hallee/scratch/hcp/reliability/permutations/permuted_condition_labels.csv')

# create results dataframe
total_rows <- n_perms * length(conds)
results <- data.frame(permutation = numeric(total_rows), cond = character(total_rows), 
                      i2c2 = numeric(total_rows), discr = numeric(total_rows), finger = numeric(total_rows))

count <- 1
for (p in 1:n_perms) {
  labels <- as.character(perm_labels[p,])
  for (cond in conds) {
    Dmax_filtered <- Dmax[labels==cond,labels==cond]
    i2c2 <- calc_i2c2(Dmax_filtered, subID, session)
    discr <- calc_discriminability(Dmax_filtered, subID)
    finger <- calc_fingerprinting(Dmax_filtered, subID)
    results[count,] <- c(p, cond, i2c2, discr, finger)
    count <- count + 1
    }
  }

# export results
write.csv(results, file='/scratch/st-tv01-1/hcp/reliability/permutations/whole_brain_mv_permutations.csv')
