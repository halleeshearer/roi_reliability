import numpy as np
import pandas as pd

# function to load a matrix given a subject ID, condition, and roi
def load_matrix(subject, condition, roi):
    output = pd.read_csv(f'/home/hallee/scratch/hcp/targets/sub{subject}_{condition}_{roi}.csv', sep=',', header=None)
    return output

# load subject list, list of conditions, and list of ROIs:
subject_list_n109 = pd.read_csv('/home/hallee/project/hcp/targets/m2m4_sub_n109.csv', header = None).squeeze()
conditions = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
rois = ['dlpfc', 'tpj', 'pre_sma']

# function to rearranged matrices into required form for i2c2 and discr analyses given a condition and subject list
def rearrange_matlab(subject_list, condition):
    # condition is either 'REST' or 'MOVIE'
    if condition == 'REST':
        ids = []
        visit = []
        matrix = pd.DataFrame()
        for roi in rois:
            for sub in subject_list:
                    for cond in ['REST1', 'REST4']:
                        if cond == 'REST1':
                            v = 1
                        elif cond == 'REST4':
                            v = 2
                        ids = ids + [sub]
                        visit = visit + [v]
                        mat = load_matrix(sub, cond, roi) # load the matrix
                        new_df = pd.DataFrame(mat.values.flatten()).transpose() # transform the matrix into a data frame
                        matrix = pd.concat([matrix, new_df]) # add the data frame to the results
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/ids_{roi}_REST_109.csv', ids, delimiter = ',') # export ID list
            matrix.to_csv(f'/home/hallee/scratch/hcp/targets/i2c2/rearranged_{roi}_REST_109.csv', index = False, header = False) # export rearranged matrix
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/visit_{roi}_REST_109.csv', visit, delimiter = ',') # export visit list
            ids = [] # reset
            visit = [] # reset
            matrix = pd.DataFrame() # reset
    elif condition == 'MOVIE': # repeat above for movie
        ids = []
        visit = []
        matrix = pd.DataFrame()
        for roi in rois:
            for sub in subject_list:
                    for cond in ['MOVIE2', 'MOVIE4']:
                        if cond == 'MOVIE2':
                            v = 1
                        elif cond == 'MOVIE4':
                            v = 2
                        ids = ids + [sub]
                        visit = visit + [v]
                        mat = load_matrix(sub, cond, roi)
                        new_df = pd.DataFrame(mat.values.flatten()).transpose()
                        matrix = pd.concat([matrix, new_df])
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/ids_{roi}_MOVIE_109.csv', ids, delimiter = ',')
            matrix.to_csv(f'/home/hallee/scratch/hcp/targets/i2c2/rearranged_{roi}_MOVIE_109.csv', index = False, header = False)
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/visit_{roi}_MOVIE_109.csv', visit, delimiter = ',')
            ids = []
            visit = []
            matrix = pd.DataFrame()

rearrange_matlab(subject_list_n109, 'REST')

rearrange_matlab(subject_list_n109, 'MOVIE')
