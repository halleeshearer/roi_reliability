# README

Steps for three ROI analysis:
1. create_new_matrices_three_rois.py
- takes BOLD data and produces FC matrices for each ROI, subject, and run

2. rearrange_three_rois.m
- rearrange the FC matrices into one large matrix where each row is a subject and visit, and the edges are across columns
- also creates a csv of subject IDs, one of condition labels, and one of visit numbers

3. ICC_three_rois.m
- takes the matlab rearranged matrix for each ROI and creates an ICC matrix (ICC for each edge)

4. dist_matrices.m
- takes the rearranged matrices from step 2 and creates distance matrices

5. mv_reliability.r
- takes the distance matrices and calculates multivariate test-retest reliability: discriminability, I2C2, fingerprinting
- uses ReX (Xu et al., 2023)

The data_amount directory includes scripts to re-run these analyses with increasing amounts of data.
