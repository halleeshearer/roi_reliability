# create condition vectors of R for Rest and M for Movie in chunks of 4 
# either MMRR or RRMM for each subject
n_perms <- 1000
n_subs <- 109

# create results dataframe to save condition label vectors
# each row is a vector of randomized condition labels (duplicated
# to represent the two visits for each subject), and each column is
# a subject and visit, i.e. sub1visit1
results <- matrix(data = NA, nrow = n_perms, ncol = n_sub*4)

# for each permutation:
for (p in 1:n_perms) {
	result <- sample(c(0, 1), size = n_sub, replace = TRUE,
						  prob = c(0.5, 0.5))
    
    vector <- c()
    for (i in 1:n_sub) {
        if (result[i] == 0) {
            vector <- c(vector, "R", "R", "M", "M")
        } else {
            vector <- c(vector, "M", "M", "R", "R")
        }
    }
	
	# save the results of this permutation into the results dfs
	results[p,] <- vector				  
}

# save the results dataframes if wanted
#write.csv(results, file = '/Users/neuroprism/Library/CloudStorage/GoogleDrive-halleeninet@gmail.com/My\ Drive/Vanderlab/ROI\ paper/roi_reliability/whole_brain/data/permuted_conditions.csv', row.names = FALSE)
# for sockeye
write.csv(results, file = '/home/hallee/scratch/hcp/reliability/permutations/permuted_condition_labels.csv', row.names = FALSE)
