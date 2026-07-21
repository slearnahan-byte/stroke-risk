# Stroke Risk Prediction: Machine Learning Pipeline

## Overview

An end-to-end machine learning project predicting stroke risk from patient demographic and clinical data.

This project demonstrates a complete ML workflow:

- Data cleaning and validation
- Exploratory data analysis
- Feature engineering
- Classification modeling
- Imbalanced learning evaluation
- Model interpretation

The focus is on building interpretable models suitable for healthcare risk prediction scenarios.

---

## Project Workflow

### 01 — Data Cleaning
- Assessed data quality and missing values
- Cleaned inconsistent entries
- Prepared structured healthcare data for analysis

### 02 — Exploratory Data Analysis
- Investigated demographic and clinical risk factors
- Analyzed relationships between features and stroke outcomes
- Evaluated class imbalance

### 03 — Feature Engineering
- Encoded categorical variables
- Prepared modeling features
- Built preprocessing workflows
- Prevented data leakage through proper train/test separation

### 04 — Model Development

Compared multiple classification approaches:

| Model | Purpose |
|---|---|
| Logistic Regression | Interpretable baseline model |
| Decision Tree | Rule-based prediction analysis |
| Random Forest | Ensemble modeling |
| LightGBM | Gradient boosting performance model |

---

## Evaluation Strategy

Because stroke outcomes are highly imbalanced, model evaluation focused on metrics beyond accuracy:

- **PR-AUC (Average Precision)** — primary optimization metric
- Recall
- Precision
- F1-score
- ROC-AUC
- Confusion matrices

Threshold optimization was performed to evaluate tradeoffs between detecting high-risk patients and limiting false positives.

---

## Model Interpretation

Interpretability analysis included:

- Logistic regression coefficients and odds ratios
- Tree-based feature importance
- Sensitivity Analysis
---

## Repository Structure
