# Fingerprint Data Amount

# Load Packages
import numpy as np
import pandas as pd
import scipy as scp
import seaborn as sb
import matplotlib as plot
import matplotlib.pyplot as plt
import scipy.stats as stats
from scipy.stats.stats import pearsonr

# Load subject list and set conditions, rois
subject_list_n109 = pd.read_csv('/home/hallee/project/hcp/targets/m2m4_sub_n109.csv', header = None).squeeze()
conditions_all = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']
conditions = ['REST','MOVIE']
rois = ['dlpfc', 'tpj', 'pre_sma']

# function to load matrix by tr
def load_matrix(subject, condition, roi, tr):
    output = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/sub{subject}_{condition}_{roi}_{tr}tr.csv', sep=',', header=None)
    return output

# list of tr's
trs = range(20, 685, 20)



# Forwards Direction

# Function to create a matrix with the correlation value between each pair of subjects for each condition and roi
def correlate_fingerprint(tr):
    start_time = time.time()
    df = pd.DataFrame(columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])
    all_data_scan1 = {}
    all_data_scan2 = {}
    for cond in ['REST', 'MOVIE']:
        print(cond)
        for roi in rois: # for each roi
            print(roi)
            for subject in subject_list_n109: # load all data in this loop
                if cond == 'REST':
                    subject1 = load_matrix(subject, f'{cond}1', roi, tr).stack().tolist() # load rest scan from day 1
                elif cond == 'MOVIE': # repeat but for movie
                    subject1 = load_matrix(subject, f'{cond}2', roi, tr).stack().tolist() # load movie scan from day 1
                all_data_scan1[subject] = subject1 # add day 1 scan to scan 1 dictionary
                subject2 = load_matrix(subject, f'{cond}4', roi, tr).stack().tolist() # load day 2 scan
                all_data_scan2[subject] = subject2 # add day 2 scan to scan 2 dictionary
            for sub1 in subject_list_n109:
                for sub2 in subject_list_n109: # for each subject
                    r = pearsonr(all_data_scan1[sub1], all_data_scan2[sub2]).statistic#.stack().tolist().statistic
                    df = pd.concat([df, pd.DataFrame(data = [[sub1, sub2, r, cond, roi]], columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])])
    print("--- %s seconds ---" % (time.time() - start_time))
    #return df
    df.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint/df_109/fingerprint_df_{tr}TR_109.csv', sep=',', index=False) # export the resulting dat$

# run with parallel processing:
if __name__ == '__main__':
# parallel processing:
    pool = mp.Pool(mp.cpu_count())
    results = pool.map(correlate_fingerprint, trs)
    pool.close()

# Use these correlation tables to find the accuacies at each TR:

def match(tr, dataDir = '/home/hallee/scratch/hcp/targets'):
    # create an empty df with cols sub1, correct, cond, roi
    df = pd.read_csv(f'{dataDir}/data_amount/fingerprint/df_109/fingerprint_df_{tr}TR_109.csv', sep=',', header = 0) #FORWARDS
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

def accuracy(tr, matched):
    results = pd.DataFrame(columns = ['cond', 'accuracy', 'roi', 'tr'])
    for roi in rois:
        roi_df = matched[matched['roi'] == roi] # filter by roi
        for cond in conditions:
            cond_df = roi_df[roi_df['cond'] == cond] # filter by condition
            acc = sum(cond_df['correct'])/cond_df.shape[0]
            result = pd.DataFrame([[cond, acc, roi, tr]], columns = ['cond', 'accuracy', 'roi', 'tr'])
            results = pd.concat([results, result])
    return results

# calculate the accuracies of each condition and roi for each tr and export as csv
def get_accuracies(tr):
    matched = match(tr)
    acc = accuracy(tr, matched)
    acc.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint/accuracy_109/accuracy_{tr}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv

# get the accuracy of all TRs for each roi and export
for roi in rois:
    results = pd.DataFrame(columns = ['TR', 'cond', 'accuracy'])
    for tr in trs:
        acc = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint/accuracy_109/accuracy_{tr}_109.csv', sep=',')
        roi_df = acc[acc['roi']==roi] # filter by roi
        for cond in ['MOVIE', 'REST']:
            cond_df = roi_df[roi_df['cond']==cond] # filter by condition
            result = pd.DataFrame([[tr, cond, cond_df.iloc[0]['accuracy']]], columns = ['TR', 'cond', 'accuracy'])
            results = pd.concat([results, result])
    results.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint/accuracy_109/accuracy_{roi}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv






# Repeat for the reverse direction

# Function to create a matrix with the correlation value between each pair of subjects for each condition and roi
def correlate_fingerprint_reverse(tr):
    start_time = time.time()
    df = pd.DataFrame(columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])
    all_data_scan1 = {}
    all_data_scan2 = {}
    for cond in ['REST', 'MOVIE']:
        print(cond)
        for roi in rois: # for each roi
            print(roi)
            for subject in subject_list_n109: # load all data in this loop
                if cond == 'REST':
                    subject2 = load_matrix(subject, f'{cond}1', roi, tr).stack().tolist() # load rest scan from day 1
                elif cond == 'MOVIE': # repeat but for movie
                    subject2 = load_matrix(subject, f'{cond}2', roi, tr).stack().tolist() # load movie scan from day 1
                all_data_scan2[subject] = subject2 # add day 1 scan to scan 1 dictionary
                subject1 = load_matrix(subject, f'{cond}4', roi, tr).stack().tolist() # load day 2 scan
                all_data_scan1[subject] = subject1 # add day 2 scan to scan 2 dictionary
            for sub1 in subject_list_n109:
                for sub2 in subject_list_n109: # for each subject
                    r = pearsonr(all_data_scan1[sub1], all_data_scan2[sub2]).statistic#.stack().tolist().statistic
                    df = pd.concat([df, pd.DataFrame(data = [[sub1, sub2, r, cond, roi]], columns = ['sub1', 'sub2', 'corr_val', 'cond', 'roi'])])
    print("--- %s seconds ---" % (time.time() - start_time))
    #return df
    df.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_reverse/df_109/r_fingerprint_df_{tr}TR_109.csv', sep=',', index=False) # export the res$

# Run this with parallel processing:
if __name__ == '__main__':
    pool = mp.Pool(mp.cpu_count())
    results = pool.map(correlate_fingerprint_reverse, trs)
    pool.close()

# Use these correlation tables to find the accuacies at each TR:

# find each subject's match
def match_r(tr, dataDir = '/home/hallee/scratch/hcp/targets'):
    # create an empty df with cols sub1, correct, cond, roi
    df = pd.read_csv(f'{dataDir}/data_amount/fingerprint_reverse/r_fingerprint_df_{tr}TR.csv', sep=',', header = 0) #FORWARDS
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

# calculate accuracy of each condition and save into new df with cond, acc, and roi
def accuracy_r(tr, matched):
    results = pd.DataFrame(columns = ['cond', 'accuracy', 'roi', 'tr'])
    for roi in rois:
        roi_df = matched[matched['roi'] == roi] # filter by roi
        for cond in conditions:
            cond_df = roi_df[roi_df['cond'] == cond] # filter by condition
            acc = sum(cond_df['correct'])/cond_df.shape[0]
            result = pd.DataFrame([[cond, acc, roi, tr]], columns = ['cond', 'accuracy', 'roi', 'tr'])
            results = pd.concat([results, result])
    return results

# calculate the accuracies of each condition and roi for each tr and export as csv
def get_accuracies_r(tr):
    matched = match_r(tr)
    acc = accuracy_r(tr, matched)
    acc.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_reverse/accuracy_109/accuracy_{tr}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv

# get the accuracy of all TRs for each roi and export
for roi in rois:
    results = pd.DataFrame(columns = ['TR', 'cond', 'accuracy'])
    for tr in trs:
        acc = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_reverse/accuracy_109/accuracy_{tr}_109.csv', sep=',')
        roi_df = acc[acc['roi']==roi] # filter by roi
        for cond in ['MOVIE', 'REST']:
            cond_df = roi_df[roi_df['cond']==cond] # filter by condition
            result = pd.DataFrame([[tr, cond, cond_df.iloc[0]['accuracy']]], columns = ['TR', 'cond', 'accuracy'])
            results = pd.concat([results, result])
    results.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_reverse/accuracy_109/accuracy_{roi}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv




# COMBINE FORWARDS AND REVERSE TO GET BIDIRECTIONAL ACCURACY FOR EACH ROI AND CONDITION:
for roi in rois:
    forwards = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint/accuracy_109/accuracy_{roi}_109.csv', sep=',') # load forwards accuracy for the roi
    forwards_movie = forwards[forwards['cond']=='MOVIE'] # get just movie accuracy for this roi
    forwards_rest = forwards[forwards['cond']=='REST'] # get just rest accuracy for this roi
    reverse = pd.read_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_reverse/accuracy_109/accuracy_{roi}_109.csv', sep=',') # repeat for reverse
    reverse_movie = reverse[reverse['cond']=='MOVIE']
    reverse_rest = reverse[reverse['cond']=='REST']
    avg_movie = pd.DataFrame(columns = ['TR', 'cond', 'accuracy']) # create empty data frame to store average movie accuracies across forwards/reverse for each tr and cond
    for row in range(forwards_movie.shape[0]): 
        avg_acc = (forwards_movie.iloc[row]['accuracy'] + reverse_movie.iloc[row]['accuracy'])/2 # calculate the average accuracy between forwards and reverse
        result = pd.DataFrame([[forwards_movie.iloc[row]['TR'], forwards_movie.iloc[row]['cond'], avg_acc]], columns = ['TR', 'cond', 'accuracy']) # save to result for that TR
        avg_movie = pd.concat([avg_movie, result]) # add to existing results
    avg_movie.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_bidir/bidir_MOVIE_accuracy_{roi}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv
    avg_rest = pd.DataFrame(columns = ['TR', 'cond', 'accuracy']) # repeat for rest
    for row in range(forwards_rest.shape[0]):
        avg_acc = (forwards_rest.iloc[row]['accuracy'] + reverse_rest.iloc[row]['accuracy'])/2
        result = pd.DataFrame([[forwards_rest.iloc[row]['TR'], forwards_rest.iloc[row]['cond'], avg_acc]], columns = ['TR', 'cond', 'accuracy'])
        avg_rest = pd.concat([avg_rest, result])
    avg_rest.to_csv(f'/home/hallee/scratch/hcp/targets/data_amount/fingerprint_bidir/bidir_REST_accuracy_{roi}_109.csv', sep=',', index=False) # export the resulting dataframe to a csv

