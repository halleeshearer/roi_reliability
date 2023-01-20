import numpy as np
import pandas as pd


def load_matrix(subject, condition, roi):
    output = pd.read_csv(f'/home/hallee/scratch/hcp/targets/sub{subject}_{condition}_{roi}.csv', sep=',', header=None)
    return output

subject_list_n111 = pd.read_csv('/home/hallee/project/hcp/targets/m2m4_sub_n111.csv', header = None).squeeze()
conditions = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
rois = ['dlpfc', 'tpj', 'pre_sma']


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
                        mat = load_matrix(sub, cond, roi)
                        new_df = pd.DataFrame(mat.values.flatten()).transpose()
                        matrix = pd.concat([matrix, new_df])
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/ids_{roi}_REST.csv', ids, delimiter = ',')
            matrix.to_csv(f'/home/hallee/scratch/hcp/targets/i2c2/rearranged_{roi}_REST.csv', index = False, header = False) 
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/visit_{roi}_REST.csv', visit, delimiter = ',')
            ids = []
            visit = []
            matrix = pd.DataFrame()
    elif condition == 'MOVIE':
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
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/ids_{roi}_MOVIE.csv', ids, delimiter = ',')
            matrix.to_csv(f'/home/hallee/scratch/hcp/targets/i2c2/rearranged_{roi}_MOVIE.csv', index = False, header = False) 
            np.savetxt(f'/home/hallee/scratch/hcp/targets/i2c2/visit_{roi}_MOVIE.csv', visit, delimiter = ',')
            ids = []
            visit = []
            matrix = pd.DataFrame()

rearrange_matlab(subject_list_n111, 'REST')

rearrange_matlab(subject_list_n111, 'MOVIE')
