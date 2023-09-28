# Fingerprint: get accuracies

# Load Packages
import numpy as np
import pandas as pd
import scipy as scp
import seaborn as sb
import matplotlib as plot
import matplotlib.pyplot as plt
import scipy.stats as stats
from scipy.stats.stats import pearsonr

# set directories
projectDir = '/home/hallee/project/hcp/targets'
dataDir = '/home/hallee/scratch/hcp/targets'

# Load subject list and set conditions, rois
subject_list_n109 = pd.read_csv(f'{projectDir}/m2m4_sub_n109.csv', header = None).squeeze()
conditions_all = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
conditions = ['REST','MOVIE']
rois = ['dlpfc', 'tpj', 'pre_sma']

# load matrix of a given subject and condition and roi
def load_matrix(subject, condition, roi):
    output = pd.read_csv(f'{dataDir}/sub{subject}_{condition}_{roi}.csv', sep=',', header=None)
    return output

# correlate each subject with every other subject within condition and roi:
# this function is unidirectional, from first scan to second scan within a condition
# repeat for the reverse direction
def correlate_fingerprint():
    df = pd.DataFrame(columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])
    for sub1 in subject_list_n109:
        for cond in conditions: 
            for roi in rois:
                if cond == 'REST':
                    subject1 = load_matrix(sub1, f'{cond}1', roi).stack().tolist()
                    for sub2 in subject_list_n109:
                        r = pearsonr(subject1, load_matrix(sub2, f'{cond}4', roi).stack().tolist())[0]
                        df = pd.concat([df, pd.DataFrame(data = [[sub1, sub2, r, cond, roi]], columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])])
                elif cond == 'MOVIE':
                    subject1 = load_matrix(sub1, f'{cond}2', roi).stack().tolist()
                    for sub2 in subject_list_n109:
                        r = pearsonr(subject1, load_matrix(sub2, f'{cond}4', roi).stack().tolist())[0]
                        df = pd.concat([df, pd.DataFrame(data = [[sub1, sub2, r, cond, roi]], columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])])
    df.to_csv('/home/hallee/scratch/hcp/targets/fingerprint/fingerprint_df_109.csv', sep=',', index=False)

correlate_fingerprint()

# find each subject's identification match
# again, this is unidirectioal so repeat for the reverse direction
def match(dataDir = '/home/hallee/scratch/hcp/targets'):
    # create an empty df with cols sub1, correct, cond, roi
    df = pd.read_csv(f'{dataDir}/fingerprint/fingerprint_df_109.csv', sep=',', header = 0) 
    results = pd.DataFrame(columns = ['sub1', 'correct', 'cond', 'roi'])
    for cond in conditions:
        df_cond = df[df['cond']== cond] #filter by condition
        for roi in rois:
            df_roi = df_cond[df_cond['roi']== roi] #filter by roi
            for sub in subject_list_n109:
                df_sub = df_roi[df_roi['sub1']==sub] #filter by sub
                if df_sub.loc[df_sub['corr_val'].idxmax()][0] == df_sub.loc[df_sub['corr_val'].idxmax()][1]:
                    correct = True
                else:
                    correct = False
                result = pd.DataFrame([[sub, correct, cond, roi]], columns = ['sub1', 'correct', 'cond', 'roi'])
                results = pd.concat([results, result])
    return results

# calculate accuracy for each roi and contition
def accuracy(matched):
    results = pd.DataFrame(columns = ['cond', 'accuracy', 'roi', 'tr'])
    for roi in rois:
        roi_df = matched[matched['roi'] == roi] # filter by roi
        for cond in conditions:
            cond_df = roi_df[roi_df['cond'] == cond] # filter by condition
            acc = sum(cond_df['correct'])/cond_df.shape[0]
            result = pd.DataFrame([[cond, acc, roi]], columns = ['cond', 'accuracy', 'roi'])
            results = pd.concat([results, result])
    return results

# calculate the accuracies of each condition and roi for each tr and export as csv
def get_accuracies():
    matched = match()
    acc = accuracy(matched)
    acc.to_csv(f'/home/hallee/scratch/hcp/targets/fingerprint/accuracy_109.csv', sep=',', index=False) # export the resulting dataframe to a csv

get_accuracies()

