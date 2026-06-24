/**************************************************************************
 * Program: 01_stroke_cleaning.sas
 * Project: Healthcare Stroke Risk Analysis
 * Author: Sophia L.
 * Last Updated: 2026-06-02
 *
 * Purpose:
 * 	Import the healthcare stroke dataset, assign variable names,
 *   inspect data quality, and create an analysis-ready dataset.
 *
 * Input: data/healthcare_stroke_raw.csv
 *
 * Output: stroke_model
 **************************************************************************/

/**************************************************************************
 * SECTION 1: IMPORT DATA
 * The file does not contain variable names
 **************************************************************************/


PROC IMPORT OUT=stroke_raw DATAFILE="/home/u63931017/DataFiles/stroke_raw.csv" 
		DBMS=CSV REPLACE;
	GETNAMES=yes;
RUN;

/* NOTE:
   This path is specific to SAS OnDemand.
   Replace with your own SAS Studio file path or local path if running elsewhere.
*/

PROC CONTENTS DATA=stroke_raw;
RUN;

PROC FREQ;
	TABLES bmi;
RUN;

/**************************************************************************
 * SECTION 2: INITIAL DATA PREPARATION
 **************************************************************************/
DATA stroke_prep;
	SET stroke_raw(RENAME=(Residence_type=residence_type));

	IF bmi="N/A" THEN
		bmi="";
	bmi_num=INPUT(bmi, best12.);
	DROP bmi;
	RENAME bmi_num=bmi;
RUN;

/**************************************************************************
 * SECTION 3: ASSESS DATA QUALITY
 **************************************************************************/
PROC MEANS N NMISS MIN MAX;
	VAR age avg_glucose_level bmi;
RUN;

PROC FREQ;
	TABLES gender hypertension heart_disease ever_married work_type residence_type 
		smoking_status stroke;
RUN;

/**************************************************************************
 * SECTION 4: CREATE CLEAN ANALYSIS DATASET
 **************************************************************************/
PROC MEANS MEDIAN;
	VAR bmi;
	OUTPUT OUT=stats MEDIAN=bmi_median;
RUN;

/* MISSING BMI (<4%): MEDIAN IMPUTATION */
DATA stroke_clean;
	IF _n_=1 THEN
		SET stats;
	SET stroke_prep;
	bmi_missing=missing(bmi);

	IF bmi_missing THEN
		bmi=bmi_median;
	DROP _TYPE_ _FREQ_ bmi_median;
RUN;

/* CLINICALLY MEANINGFUL GROUPS */
DATA stroke_clean;
	LENGTH bmi_cat $20 diabetes_cat $20;
	SET stroke_clean;

	IF bmi < 18.5 THEN
		bmi_cat="Underweight";
	ELSE IF bmi < 25 THEN
		bmi_cat="Normal";
	ELSE IF bmi < 30 THEN
		bmi_cat="Overweight";
	ELSE IF bmi < 35 THEN
		bmi_cat="Obesity I";
	ELSE IF bmi < 40 THEN
		bmi_cat="Obesity II";
	ELSE
		bmi_cat="Severe Obesity";

	IF avg_glucose_level <=114 THEN
		diabetes_cat="Normal";
	ELSE IF avg_glucose_level <=152 THEN
		diabetes_cat="Prediabetes";
	ELSE
		diabetes_cat="Diabetes";
RUN;

/**************************************************************************
 * SECTION 5: VALIDATE CLEANED DATA
 **************************************************************************/
PROC CONTENTS DATA=stroke_clean;
RUN;

PROC MEANS DATA=stroke_clean N NMISS MIN MAX;
RUN;

PROC FREQ;
	TABLES gender hypertension heart_disease ever_married work_type residence_type 
		smoking_status bmi_cat diabetes_cat stroke;
RUN;

DATA stroke_clean;
	RETAIN id stroke age gender ever_married residence_type work_type bmi bmi_cat 
		bmi_missing avg_glucose_level diabetes_cat hypertension heart_disease;
	SET stroke_clean;
RUN;

DATA stroke_model;
	SET stroke_clean;
	LABEL bmi="Body Mass Index (imputed)" bmi_cat="BMI Clinical Category" 
		bmi_missing="BMI Missing Indicator" 
		avg_glucose_level="Average Glucose Level (mg/dL)" 
		diabetes_cat="Glycemic Risk Category";
RUN;

/**************************************************************************
 * SECTION 6: EXPORT
 **************************************************************************/
PROC EXPORT DATA=stroke_model 
		OUTFILE="/home/u63931017/DataFiles/stroke_model.csv" DBMS=CSV REPLACE;
RUN;
