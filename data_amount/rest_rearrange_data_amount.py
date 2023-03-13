import multiprocessing as mp
import numpy as np
import pandas as pd

def load_matrix(subject, condition, roi, tr):
    output = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/sub{subject}_{condition}_{roi}_{tr}tr.csv', sep=',', header=None)
    return output

subject_list = pd.read_csv('/home/hallee/project/hcp/targets/m2m4_sub_n109.csv', header = None).squeeze()
conditions = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
rois = ['dlpfc', 'tpj', 'pre_sma']
trs = range(20, 680, 20)


def rearrange_matlab_rest(tr):
    # condition is either 'REST' or 'MOVIE'
    matrix = pd.DataFrame()
    for roi in rois:
        for sub in subject_list:
            for cond in ['REST1', 'REST4']:
                mat = load_matrix(sub, cond, roi, tr)
                new_df = pd.DataFrame(mat.values.flatten()).transpose()
                matrix = pd.concat([matrix, new_df])
        matrix.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/i2c2/rearranged/rearranged_{roi}_REST_{tr}tr_109.csv', index = False, header = False)
        matrix = pd.DataFrame()


pool = mp.Pool(mp.cpu_count())
results = pool.map(rearrange_matlab_rest, trs)
pool.close()
