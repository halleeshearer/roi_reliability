# README

Steps for three ROI analysis:
1. create_new_matrices_three_rois.py
- takes BOLD data and produces FC matrices for each ROI, subject, and run

2. rearrange_matrices_three_rois.m
- rearrange the FC matrices into one large matrix where each row is a subject and visit, and the edges are across columns
- also creates a csv of subject IDs, one of condition labels, and one of visit numbers

3. icc_three_rois.m
- takes the matlab rearranged matrix for each ROI and creates an ICC matrix (ICC for each edge)

4. 