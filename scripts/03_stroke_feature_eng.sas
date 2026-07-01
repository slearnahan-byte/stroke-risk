/**************************************************************************
* Program: 03_stroke_feature_eng.sas
* Project: Healthcare Stroke Risk Analysis
* Author: Sophia L.
* Last Updated: 2026-06-28
*
* Purpose:
* 	To transform the cleaned stroke dataset into a model-ready analytic dataset by creating clinically 
*	meaningful categorical variables, applying transformations to address skewed distributions, informed 
*	by exploratory data analysis to improve suitability for predictive modeling.
*
* Input: data/stroke_clean.csv
*
**************************************************************************/

/**************************************************************************
* SECTION 1: IMPORT DATA 
**************************************************************************/

PROC IMPORT 
	OUT = stroke_clean
	DATAFILE = "/home/u63931017/DataFiles/stroke_clean.csv"
	DBMS = CSV REPLACE;
	GETNAMES = yes;
RUN;

/**************************************************************************
* SECTION 2: FEATURE ENGINEERING
**************************************************************************/

DATA stroke_model;
	SET stroke_clean;
	LENGTH bmi_cat $20 diabetes_cat $20;

/* CREATE CLINICALLY MEANINGFUL CATEGORIES FOR BMI AND GLUCOSE
   BASED ON CLINICALLY DEFINED THRESHOLDS */
 
	IF bmi < 18.5 THEN
		bmi_cat = "Underweight";
	ELSE IF bmi < 25 THEN
		bmi_cat = "Normal";
	ELSE IF bmi < 30 THEN
		bmi_cat = "Overweight";
	ELSE IF bmi < 35 THEN
		bmi_cat = "Obesity I";
	ELSE IF bmi < 40 THEN
		bmi_cat = "Obesity II";
	ELSE
		bmi_cat = "Severe Obesity";

	IF avg_glucose_level < = 117 THEN
		diabetes_cat = "Normal";
	ELSE IF avg_glucose_level < = 154 THEN
		diabetes_cat = "Prediabetes";
	ELSE
		diabetes_cat = "Diabetes";
		
/* CREATE TRANSFORMED VARIABLES FOR CONTINUOUS VARIABLE FOUND TO BE SKEWED IN THE FIRST ITERATION OF 
   02_stroke_eda DONE ON CLEAN DATA*/
   log_bmi  =  log(bmi);
	
	LABEL 
		log_bmi  =  "Log-transformed BMI"
		bmi_cat  =  "BMI Clinical Category"
		diabetes_cat  =  "Glycemic Risk Category";
RUN;


/**************************************************************************
 * SECTION 3: FINALIZE AND EXPORT
 **************************************************************************/
PROC EXPORT DATA = stroke_model 
		OUTFILE = "/home/u63931017/DataFiles/stroke_model.csv" DBMS = CSV REPLACE;
RUN;
