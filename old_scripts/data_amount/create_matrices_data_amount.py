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

import multiprocessing as mp


# load Schaefer parcellation, remove medial wall
schaefer = nb.cifti2.load('/home/hallee/project/atlas/schaefer2018/Schaefer2018_1000Parcels_7Networks_order.dscalar.nii').get_fdata().squeeze()
medial = nb.cifti2.load('/home/hallee/project/atlas/HCP_S1200/Human.MedialWall_Conte69.32k_fs_LR.dlabel.nii').get_fdata().squeeze()
schaefer = schaefer[medial == 0]


# load my ROIs...

dlpfc = nb.load('/home/hallee/hallee/ROIs/dlpfc.dscalar.nii')
pre_sma = nb.load('/home/hallee/hallee/ROIs/pre-sma.dscalar.nii')
tpj = nb.load('/home/hallee/hallee/ROIs/tpj.dscalar.nii')

# load data

def load_file(subject, condition):
    # file is the path in '' to the .dtseries.nii file to be loaded
    # returns a numpy array of grayordinates by timepoints
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
    X = nb.load(f"/home/hallee/project/hcp/data-clean/{subject}_7T/{rt}fMRI_{condition}_7T_{phase}_Atlas_hp2000_clean.dtseries.nii").get_fdata()
    return X[:, hcp.struct.cortex]

# NEW!!! for data amount...

# create a function that takes an array of grayordinates by time and a number of TRs to include, and filters 
def crop(array, num_of_trs, cond):
    index = np.zeros(array.shape[0])
    for n in range(num_of_trs):
        index[n] = 1
    return array[index == 1, :]



# produces the path (str) to the correct index file in sockeye for filtering the timecourse
# rest1 and movie2 should be indexed by movie2_vols, rest4 and movie4 should be indexed by movie4_vols

def index_path(condition):
    if condition == 'REST1' or condition == 'MOVIE2':
        path = '/home/hallee/project/hcp/targets/movie2_vols.csv'
    elif condition == 'REST4' or condition == 'MOVIE4':
        path = '/home/hallee/project/hcp/targets/movie4_vols.csv'
    return path



# filters an np array of grayordinates x time with an index where 1 means to keep the volume, and 0 discard

def filter_tc(index, array): # takes an index of which volumes to cut out and an np array of grayordinates x time
    idx = pd.read_csv(index, header = None).values.squeeze() # import the index file from csv as a list
    len_idx = len(idx) # find the length of the index
    len_array = array.shape[0] # find the length of the 0th dimension of the array (time)
    if len_idx < len_array: # if the length of the index is less than the length of time in the array, 
        array = array[range(0,len_idx),:] # crop the array time dimension to the length of the index
    elif len_idx > len_array: # if the length of the index is more than the length of time in the array,
        idx = idx[0:len_array] # crop the index to the length of the time dimension of the array
    out = array[idx == 0, :] # index the array with index
    return out # return the output as the indexed array


# extract ROI timeseries

def roi_tc(roi, image):
    roi_for_mask = roi.get_fdata().squeeze().astype(int) # make mask into np array of 1 or 0
    Xn_for_mask = image[:, hcp.struct.cortex] # select cortex from Xn
    roi = Xn_for_mask[:, roi_for_mask==1]
    return roi


# parcellation to timeseries compatible with schaeffer
# return # of parcels x time np array

# *IMPORTANT* need to use cortex cifti data for this to run... in the example, I used Xcortex as cifti

def parcellate(parcellation, cifti):
    # assume parcellation and cifti are both arrays
    # loop over each parcel, get the average in the cifti
    num_of_parcels = np.unique(parcellation) 
    num_of_parcels = num_of_parcels[num_of_parcels != 0].astype(int)
    output = np.empty((cifti.shape[0], max(num_of_parcels)))
    for parcel in num_of_parcels:
        idx = parcellation == parcel
        output[:, parcel-1] = cifti[:, idx].mean(axis=1) 
    return output

# compute the overlap between parcellation and an ROI
# inputs: parcellation, roi, optional threshold (what proportion of the voxels in a parcel need to overlap to exclude)
# return: the indices that we want to keep (without overlap)

def overlap(parcellation, roi, thresh=0):
    num_of_parcels = np.unique(parcellation) 
    num_of_parcels = num_of_parcels[num_of_parcels != 0].astype(int)
    proportion = np.zeros(max(num_of_parcels)) # 1000-long list of entries, not initialized
    roi = roi.get_fdata().squeeze()
    for parcel in num_of_parcels:
        idx = parcellation == parcel
        proportion[parcel-1] = roi[idx].mean()
    proportion[532] = 1
    proportion[902] = 1
    return proportion <= thresh



# filter the parcellation to remove parcels with overlap from overlap() function
# input: list of parcels to include, np array of time by parcels
def filter_parcellation(parcels, array):
    output = array[:, parcels == True]
    return output


def create_matrix_array_cropped(subject, condition, roi, parcellation, threshold, num_of_trs):
    cortex = load_file(subject, condition)
    index = index_path(condition)
    cortex = filter_tc(index, cortex)
    cropped = crop(cortex, num_of_trs, condition)
    roi_time = roi_tc(roi, cropped)
    brain_parcellated = parcellate(parcellation, cropped)
    overlapping = overlap(parcellation, roi, threshold)
    parcel_tc = filter_parcellation(overlapping, brain_parcellated)
    matrix = np.transpose(np.corrcoef(roi_time, parcel_tc, rowvar = False)[roi_time.shape[1]:,:roi_time.shape[1]])# old code: get_corr_matrix(roi_time, parcel_tc)
    return matrix

def get_all_matrices(sub):
    condition_list = ['REST1', 'REST4', 'MOVIE2',  'MOVIE4'] # 4 conditions
    roi_list = [dlpfc, pre_sma, tpj] # 3 ROIs
    parcellation = schaefer
    threshold = 0
    for c in condition_list:
        for r in roi_list:
            if r == dlpfc:
                r_string = 'dlpfc'
            elif r == pre_sma:
                r_string = 'pre_sma'
            elif r == tpj:
                r_string = 'tpj'
            for tr in range(5,10):
                output = create_matrix_array_cropped(sub, c, r, parcellation, threshold, tr)
                np.savetxt(f'/home/hallee/scratch/hcp/targets/data_amount/sub{sub}_{c}_{r_string}_{tr}tr.csv', output, delimiter = ',')



# run get_all_matrices() with parallel processing!

pool = mp.Pool(mp.cpu_count())
results = pool.map(get_all_matrices, subject_list_n111)
pool.close()
