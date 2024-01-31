### INSTRUCTIONS
This folder contains the scripts and functions necessary to reproduce the whole-brain analysis comparing the test-retest reliability of Movie to Rest FC data for each region of the Glasser atlas (including subcortical ROIs)

*Step 1.* create matrices for each ROI, subject, and run (create_matrices_all_rois.py)

*Step 2.* rearrange those matrices to adhere to ReX input requirements (rearrange_matrices.R)

*Step 3.* calculate multivariate reliability (i2c2, fingerprinting, discriminability) for each roi and condition (calculate_mv.R)

*Step 4.* calculate statistics (TODO)

### NOTES
- larger ROIs (i.e. V1, primary motor) have trouble with step 3, and likely will with step 4 too. As of Jan 29, 2024 
