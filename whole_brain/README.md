### INSTRUCTIONS
This folder contains the scripts and functions necessary to reproduce the whole-brain analysis comparing the test-retest reliability of Movie to Rest FC data for each region of the Glasser atlas (including subcortical ROIs)

1. create_matrices/create_matrices_all_rois.py
- create matrices for each ROI, subject, and run

2. rearrange_matrices/rearrange_matrices.R
- rearrange those matrices to adhere to ReX input requirements

3. distance_matrices/create_dist_matrices.m
- takes rearranged matrices and creates distance matrices

4. multivariate_reliability/calculate_mv.R
- takes distance matrices and calculates multivariate reliability (I2C2, fingerprinting, discriminability) for each ROI and condition
- uses ReX (Xu et al., 2023)

5. permutation_tests/create_condition_permutations.R
- creates many permuted lists of condition labels by shuffling condition labels for each subject with a 50% probability

6. permutation_tests/roi_permutation_testing.R
- takes permuted condition labels and creates null distributions for each ROI

7. permutation_tests/roi_p_values.R
- takes null distributions and observed differences between conditions and calculates p-values
- TODO: clean up

