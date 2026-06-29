/**************************************************************************
 * Program: 01_stroke_cleaning.sas
 * Project: Healthcare Stroke Risk Analysis
 * Author: Sophia L.
 * Last Updated: 2026-06-28
 *
 * Purpose:
 * 	Import the healthcare stroke dataset, clean and validate the data,
 *	handle missing values, and create an analysis-ready dataset.
 *
 * Input: data/healthcare_stroke_raw.csv
 *
 * Output: stroke_clean
 **************************************************************************/

/**************************************************************************
 * SECTION 1: IMPORT DATA
 **************************************************************************/


PROC IMPORT OUT=stroke_raw DATAFILE="/home/u63931017/DataFiles/stroke_raw.csv" 
		DBMS=CSV REPLACE;
	GETNAMES=yes;
RUN;

/* NOTE:
   This path is specific to SAS OnDemand.
   Replace with your own SAS Studio file path or local path if running elsewhere.
*/

PROC PRINT DATA=stroke_raw (OBS=10);
RUN;

PROC CONTENTS DATA=stroke_raw VARNUM;
RUN;

/* BMI hold character data type - likely includes NA
   confirm with
   
   PROC FREQ DATA=stroke_raw;
   	TABLES bmi;
   RUN;
   
   and clean/convert to numeric
*/

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

PROC MEANS DATA=stroke_prep
	N NMISS MIN MAX;
	VAR age avg_glucose_level bmi;
RUN;

PROC FREQ DATA=stroke_prep;
	TABLES gender hypertension heart_disease ever_married work_type residence_type 
		smoking_status stroke;
RUN;

/**************************************************************************
 * SECTION 4: CREATE A CLEAN ANALYSIS DATASET
 **************************************************************************/
/* CALC MEDIAN FOR IMPUTATION */
PROC MEANS DATA=stroke_prep NOPRINT;
	VAR bmi;
	OUTPUT OUT=stats MEDIAN=bmi_median;
RUN;

/* SET FORMATTING RULES */
PROC FORMAT;
	VALUE yesno
	0 = "No"
	1 = "Yes";
RUN;


DATA stroke_clean;
/* MISSING BMI (<4%): MEDIAN IMPUTATION */

	IF _n_=1 THEN
		SET stats;
	SET stroke_prep;
	bmi_missing=missing(bmi);

	IF bmi_missing THEN
		bmi=bmi_median;
	DROP _TYPE_ _FREQ_ bmi_median;
		
	RETAIN id stroke age gender ever_married residence_type work_type bmi 
		bmi_missing avg_glucose_level hypertension heart_disease;
	LABEL bmi="Body Mass Index (imputed)" 
		bmi_missing="BMI Missing Indicator" 
		avg_glucose_level="Average Glucose Level (mg/dL)";
	FORMAT hypertension heart_disease stroke bmi_missing yesno.;

RUN;
  
/**************************************************************************
 * SECTION 5: VALIDATE CLEANED DATA
 **************************************************************************/
PROC CONTENTS DATA=stroke_clean;
RUN;

PROC MEANS DATA=stroke_clean N NMISS MIN MAX;
RUN;

PROC FREQ DATA=stroke_clean;
	TABLES gender hypertension heart_disease ever_married work_type residence_type 
		smoking_status stroke;
RUN;

/**************************************************************************
 * SECTION 6: FINALIZE AND EXPORT
 **************************************************************************/
PROC EXPORT DATA=stroke_clean 
		OUTFILE="/home/u63931017/DataFiles/stroke_clean.csv" DBMS=CSV REPLACE;
RUN;
