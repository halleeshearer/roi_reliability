# import packages
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
from nilearn.masking import apply_mask
from nilearn.maskers import NiftiLabelsMasker
from nilearn import plotting
from nilearn.image import mean_img
import os


# change these if necessary 
dataDir = '/home/hallee/project/hcp/data-clean'
subject_list_n109 = pd.read_csv('/arc/project/st-tv01-1/hcp/targets/m2m4_sub_n109.csv', header = None).squeeze()
conditions = ['REST1', 'REST4', 'MOVIE2', 'MOVIE4']

######################################################################

# helper functions:

# load data from a given subject and condition
def load_file(subject, condition, dataDir= dataDir):
    # returns a numpy array of grayordinates by timepoints with 91282 grayordinates
    # condition is one of REST1, REST4, MOVIE2, MOVIE4
    if condition == 'REST1':
        rt = 'r'
        phase = 'PA'
    elif condition == 'REST4':
        rt = 'r'
        phase = 'AP'
    elif condition == 'MOVIE2':
        rt = 't'
        phase = 'PA'
    elif condition == 'MOVIE4':
        rt = 't'
        phase = 'AP'
    X = nb.load(f"{dataDir}/{subject}_7T/{rt}fMRI_{condition}_7T_{phase}_Atlas_hp2000_clean.dtseries.nii").get_fdata()
    return X

# produce the path (str) to the correct index file in sockeye for filtering the timecourses to remove
# chunks of rest from movie runs, and corresponding chunks from rest runs
# rest1 and movie2 should be indexed by movie2_vols, rest4 and movie4 should be indexed by movie4_vols
path_to_indices = '/scratch/st-tv01-1/hcp/targets/hallee_hcp_targets-main/'
def index_path(condition):
    if condition == 'REST1' or condition == 'MOVIE2':
        path = os.path.join(path_to_indices, 'data/movie2_vols.csv')
    elif condition == 'REST4' or condition == 'MOVIE4':
        path = os.path.join(path_to_indices, 'data/movie4_vols.csv')
    return path

def filter_tc(index, array): # takes path to an index of which volumes to cut out and an np array of grayordinates x time
    idx = pd.read_csv(index, header = None).values.squeeze() # import the index file from csv as a list
    len_idx = len(idx) # find the length of the index
    len_array = array.shape[0] # find the length of the 0th dimension of the array (time)
    if len_idx < len_array: # if the length of the index is less than the length of time in the array, 
        array = array[range(0,len_idx),:] # crop the array time dimension to the length of the index
    elif len_idx > len_array: # if the length of the index is more than the length of time in the array,
        idx = idx[0:len_array] # crop the index to the length of the time dimension of the array
    out = array[idx == 0, :] # index the array with index
    return out # return the output as the indexed array

######################################################################

def create_matrices(sub):

    # loop through conditions:
    for cond in conditions:
        # load timeseries data (vertex x time)
        ts = load_file(sub, cond)
        # parcellate timeseries data with Glasser parcellation (includes subcortical)
        # (Glasser parcellation is hcp.mmp in the hcp_utils package)
        parcellated_ts = hcp.parcellate(ts, hcp.mmp)

        # filter the vertex-wise and parcellated timeseries data temporally
        # to remove chunks of rest from movie runs, and temporally corresponding
        # chunks from rest runs
        filtered_parcellated_ts = filter_tc(index_path(cond), parcellated_ts)
        filtered_vertex_ts = filter_tc(index_path(cond), ts)

        # loop through all of the regions in the Glasser atlas
        for roi in range(1,hcp.mmp.ids.shape[0]):
            # create a logical vector that is True for vertices in this roi
            roi_idx = hcp.mmp.map_all == roi
            # keep those vertices in this roi
            roi_vert_ts = filtered_vertex_ts[:,roi_idx]
            # correlate roi vertices with parcellated region timecourses
            # note: np.corrcoef function takes x and y and create a corr matrix of shape (x.shape[0]+y.shape[0] x x.shape[1]+y.shape[1])
            #   this means that we need to index out just the part of the matrix that is x by y, so we exclude x by x and y by y and the duplicate
            mat = np.corrcoef(roi_vert_ts, filtered_parcellated_ts, rowvar=False)[roi_vert_ts.shape[1]:,:roi_vert_ts.shape[1]]
            # export the results
            np.savetxt(f'/scratch/st-tv01-1/hcp/reliability/matrices/{str(sub)}/{cond}/roi_{roi}.csv', mat, delimiter = ',')

pool = mp.Pool(mp.cpu_count())
results = pool.map(create_matrices, subject_list_n109)
pool.close()
