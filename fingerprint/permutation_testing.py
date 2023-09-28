import numpy as np
import pandas as pd
import scipy as scp
import seaborn as sb
import nilearn as nl
import nibabel as nb
import sklearn as skl
import hcp_utils as hcp
import matplotlib as plot
import nilearn.plotting as plotting
import matplotlib.pyplot as plt
import scipy.stats as stats


subject_list_n111 = pd.read_csv('/home/hallee/project/hcp/targets/m2m4_sub_n111.csv', header = None).squeeze()
conditions_all = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
conditions = ['REST','MOVIE']
rois = ['dlpfc', 'tpj', 'pre_sma']

# set directories:
targetDir = '/home/hallee/scratch/hcp/targets'
ourDir = '/home/hallee/scratch/hcp/targets/fingerprint_permutations'


def load_matrix(subject, condition, roi, targetDir= targetDir):
    output = pd.read_csv(f'{targetDir}/sub{subject}_{condition}_{roi}.csv', sep=',', header=None)
    return output
  
# this is all unidirectional, repeat for the reverse direction after!

# function #1: create a df with cols: sub1, correct (binary true or false), cond, roi
def match(dataDir = targetDir):
    # create an empty df with cols sub1, correct, cond, roi
    df = pd.read_csv(f'{dataDir}/fingerprint_df.csv', sep=',', header = 0)
    results = pd.DataFrame(columns = ['sub1', 'correct', 'cond', 'roi'])
    for cond in conditions:
        df_cond = df[df['cond']== cond] #filter by condition
        for roi in rois:
            df_roi = df_cond[df_cond['roi']== roi] #filter by roi
            for sub in subject_list_n111:
                df_sub = df_roi[df_roi['sub1']==sub] #filter by sub
                if df_sub.loc[df_sub['corr_val'].idxmax()][0] == df_sub.loc[df_sub['corr_val'].idxmax()][1]:
                    correct = True
                else:
                    correct = False
                result = pd.DataFrame([[sub, correct, cond, roi]], columns = ['sub1', 'correct', 'cond', 'roi'])
                results = pd.concat([results, result])
    return results
 

# function #2: shuffle the condition column from the match() result
def shuffle(p, match, dataDir= targetDir):
    results = pd.DataFrame(columns = ['sub1', 'correct', 'cond', 'roi'])
    df = pd.read_csv(f'{dataDir}/fingerprint_df.csv', sep=',', header = 0)
    for roi in rois:
        df_roi = match[match['roi'] == roi] # filter by roi
        df_without_cond = df_roi[['sub1', 'correct', 'roi']].reset_index()[['sub1', 'correct', 'roi']]
        df_shuffle_cond = df_roi['cond'].sample(frac = 1, random_state = p).reset_index()['cond']
        shuffled_df = df_without_cond.assign(cond = df_shuffle_cond)
        results = pd.concat([results, shuffled_df])
    return results

  
  
# function #3: calculate accuracy of each condition and save into new df with cond, acc, and roi
def accuracy(p, shuffled):
    results = pd.DataFrame(columns = ['cond', 'accuracy', 'roi', 'permutation'])
    for roi in rois:
        roi_df = shuffled[shuffled['roi'] == roi] # filter by roi
        for cond in conditions:
            cond_df = roi_df[roi_df['cond'] == cond] # filter by condition
            acc = sum(cond_df['correct'])/cond_df.shape[0]
            result = pd.DataFrame([[cond, acc, roi, p]], columns = ['cond', 'accuracy', 'roi', 'permutation'])
            results = pd.concat([results, result])
    return results
 

# put all 3 functions together to do multiple permutations:
def permutation_testing(num):
    results = pd.DataFrame(columns = ['cond', 'accuracy', 'roi', 'permutation'])
    for p in range(num):
        matched = match()
        shuffled = shuffle(p, matched)
        acc = accuracy(p, shuffled)
        results = pd.concat([results, acc])
    return results

 
# for each permutation and roi, calculate movie-rest
# takes the result from permutation_testing() function
def movie_rest_perm(perms):
    results = pd.DataFrame(columns = ['movie-rest', 'roi', 'permutation'])
    for p in range(len(perms['permutation'].unique())):
        df = perms[perms['permutation']==p] 
        for roi in rois:
            df_roi = df[df['roi']==roi]
            m_r = (df_roi[df_roi['cond']== 'MOVIE'].iloc()[0,1] - df_roi[df_roi['cond']== 'REST'].iloc()[0,1])
            result = pd.DataFrame([[m_r, roi, p]], columns = ['movie-rest', 'roi', 'permutation'])
            results = pd.concat([results, result])
    return results
           
    
  
  
 # function that takes results from movie_res_perm() and exports the distribution as a csv for each roi
def export_distributions(results, num, outDir= ourDir):
    for roi in rois:
        df = results[results['roi']==roi]
        dist = df['movie-rest']
        pd_dist = pd.DataFrame(dist)
        pd_dist.to_csv(f'{outDir}/{roi}_dist_{num}.csv')
        print(f'the 95th percentile cutoff of the {roi} is:', np.percentile(dist, 95))
    
 
def permutations(num):
    perms = permutation_testing(num)
    results = movie_rest_perm(perms)
    export_distributions(results, num)
   
  
# permutations(num) where num is the number of permutations to compute
permutations(5000)
