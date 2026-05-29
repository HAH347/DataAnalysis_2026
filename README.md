1. Assignment Description
This assignment compares two missing value imputation methods:
PMM (Predictive Mean Matching)
RF (Random Forest)
Goal: Identify which method better preserves the original data distribution for downstream statistical analysis.
2. Data Description
Data type: Quantitative hormone, lipid, antioxidant, and metabolism data
Key target variable: hormone10_generated (used for density curve comparison)
Variables included:
Hormones: hormone1–14, hormone10_generated
Lipids: lipids1–5
Antioxidants: antioxidant1–5
Lipid peroxidation: lipid_pero1–5
Carbohydrate metabolism: carb_metabolism
Missing value ratio: 18.6% missing | 81.4% present
3. Software Environment
Language: R
R version: 4.3.1 (or your actual version)
Packages used:
mice – for PMM interpolation
randomForest – for RF interpolation
ggplot2 – density plot visualization
dplyr, tidyr – data cleaning
4. Analysis Procedures (Full Step-by-Step)
Load raw dataset and inspect structure
Calculate and visualize missing value proportion
Perform missing value interpolation using PMM
Perform missing value interpolation using Random Forest
Generate density curves for:
Original data
PMM-imputed data
RF-imputed data
Compare distribution shape, bias, and fidelity to original
Summarize performance and recommend best method
5. Main Results
PMM:
Density curve highly consistent with original data
Preserves distribution shape and statistical characteristics
Higher fidelity for distribution-sensitive analysis
RF:
Captures nonlinear variable relationships
Shows minor local bias in density curve
Lower fidelity to original distribution
6. Conclusion
PMM is better for tasks requiring preservation of original data distribution.
RF is better for exploring nonlinear relationships between variables.
