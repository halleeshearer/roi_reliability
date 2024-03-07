# README

Steps for three ROI analysis:
1. create_new_matrices_three_rois.py
- takes BOLD data and produces FC matrices for each ROI, subject, and run

2. rearrange_matrices_three_rois.py
- rearrange the FC matrices into one large matrix where each row is a subject and visit, and the edges are across columns
- saves one copy that has the first three columns as subject, visit, and condition, and another copy without those first three columns so it can be read into matlab as a matrix (faster)

3. icc_three_rois.m
- takes the matlab rearranged matrix for each ROI and creates an ICC matrix (ICC for each edge)

4. 