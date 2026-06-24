# stroke-risk-sas
Statistical analysis of stroke risk (2018 BRFSS) using SAS software. 

This project analyzes stroke risk using a subset of the 2018 BRFSS dataset, a large-scale health survey conducted by the Centers for Disease Control and Prevention, obtained from Kaggle.

The goal is to:

Clean and prepare survey data in SAS
Provide descriptive statistics to explore relationships between health indicators and stroke
Build diagnostic/predictive logistic regression models to identify key risk factors

Dataset
Source: Kaggle (public dataset)
Derived from: Behavioral Risk Factor Surveillance System (BRFSS)

Includes variables such as:
Age
Gender
Ever Married
Residence Type
Work Type
BMI
Average Glucose Level
Smoking status
Hypertension
History of Heart Disease
Stroke history (target variable)

`01_stroke_cleaning.sas` 
Cleans and preprocesses the raw dataset, including handling missing values and recoding variables.

`02_stroke_eda.sas` 
Performs exploratory data analysis, including summary statistics and visualizations.

`03_stroke_modeling.sas`  Builds and evaluates logistic regression models to predict stroke risk.
