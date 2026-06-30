/**************************************************************************
* Program: 02_stroke_eda.sas
* Project: Healthcare Stroke Risk Analysis
* Author: Sophia L.
* Last Updated: 2026-06-28
*
* Purpose:
* 	Perform exploratory data analysis (EDA) on the stroke dataset to
* 	summarize variable distributions, assess relationships between clinical
* 	risk factors and stroke occurrence, and generate visual and statistical
*	insights to support subsequent predictive modeling.	
*
*   NOTE: EDA was performed on the cleaned dataset (stroke_clean) 
*   and the final analysis dataset (stroke_model) 
*   to assess variable distributions, outliers, and relationships with stroke outcome 
*   before and after feature engineering.
*
* Input: data/stroke_model.csv
*
**************************************************************************/

/**************************************************************************
* SECTION 1: IMPORT DATA 
**************************************************************************/

PROC IMPORT 
	OUT=stroke_data
	/* first EDA iteraction had datafile = ... /stroke_clean.csv */
	DATAFILE="/home/u63931017/DataFiles/stroke_model.csv" 
	DBMS=CSV REPLACE;
	GETNAMES=yes;
RUN;

/**************************************************************************
* SECTION 2: UNIVARIATE ANALYSIS
**************************************************************************/

/* 2.1 DESCRIPTIVE STATISTICS */

PROC MEANS DATA=stroke_data n nmiss mean std min p25 median p75 max;
	VAR 
		age bmi log_bmi avg_glucose_level;
RUN;

PROC FREQ DATA=stroke_data;
	TABLES 
		gender ever_married residence_type smoking_status hypertension 
		heart_disease diabetes_cat bmi_cat stroke;
RUN;

/* 2.2 VISUAL ASSESSMENT*/

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Patient Age";
    HISTOGRAM age;
    DENSITY age;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Body Mass Index (BMI)";
    HISTOGRAM bmi;
    DENSITY bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Logarithmic Body Mass Index (BMI)";
    HISTOGRAM log_bmi;
    DENSITY log_bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Average Glucose Levels (mg/dL)";
    HISTOGRAM avg_glucose_level;
    DENSITY avg_glucose_level;
RUN;

%macro univariate_bar(var);

PROC SGPLOT DATA=stroke_data;
    TITLE "Frequency Distribution of &var";
    VBAR &var;
RUN;

%mend;

%univariate_bar(gender);
%univariate_bar(ever_married);
%univariate_bar(residence_type);
%univariate_bar(smoking_status);
%univariate_bar(hypertension);
%univariate_bar(heart_disease);
%univariate_bar(diabetes_cat);
%univariate_bar(bmi_cat);


/* 2.3 DISTRIBUTION ASSESSMENT:

   Age: Core values follow a normal pattern; heavy tails suggest outliers deviate
   BMI: Moderate right skew - therefore, a log-transformed version (log_bmi) was created 
   in the feature engineering stage and assessed for improved normality.
   Average Glucose: Clear non-normal pattern, bimodal - consider categorical representation of avg. glucose*/

PROC UNIVARIATE DATA=stroke_data NORMAL;
    TITLE "Normality Tests for Continuous Variables";
    VAR age log_bmi bmi avg_glucose_level;
    QQPLOT age log_bmi bmi avg_glucose_level / NORMAL(MU=EST SIGMA=EST);
RUN;

/* 2.4 IDENTIFY POTENTIAL OUTLIERS 

 Boxplots were used to identify potential outliers in age, BMI, and
 average glucose level. Although extreme BMI values
 (maximum BMI = 97.6) and extreme average glucose levels (max avg = 271.74) were observed.
 
 These records were retained because they are plausible clinical values 
 and reflect the right-skewed distributions rather than obvious data-entry errors.
*/

PROC SGPLOT DATA=stroke_data; 
    TITLE "Age Distribution & Outliers";
    VBOX age;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "BMI Distribution & Outliers";
    VBOX bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Log(BMI) Distribution & Outliers";
    VBOX log_bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Average Glucose Distribution & Outliers";
    VBOX avg_glucose_level;
RUN;

/**************************************************************************
* SECTION 3: BIVARIATE ANALYSIS WITH STROKE OUTCOME 
**************************************************************************/

/* 3.1 VISUAL ASSESSMENT */

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Patient Age by Stroke Outcome";
    HISTOGRAM age / GROUP = stroke TRANSPARENCY=0.5;
    DENSITY age;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Body Mass Index (BMI) by Stroke Outcome";
    HISTOGRAM bmi / GROUP = stroke TRANSPARENCY=0.5;
    DENSITY bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Logarithmic Body Mass Index (BMI) by Stroke Outcome";
    HISTOGRAM log_bmi / GROUP = stroke TRANSPARENCY=0.5;
    DENSITY log_bmi;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Distribution of Average Glucose Levels (mg/dL) by Stroke Outcome";
    HISTOGRAM avg_glucose_level / GROUP = stroke TRANSPARENCY=0.5;
    DENSITY avg_glucose_level;
RUN;

PROC SGPLOT DATA=stroke_data; 
    TITLE "Age Distribution & Outliers by Stroke Outcome";
    VBOX age / GROUP=stroke;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "BMI Distribution & Outliers by Stroke Outcome";
    VBOX bmi / GROUP=stroke;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Log(BMI) Distribution & Outliers by Stroke Outcome";
    VBOX log_bmi / GROUP=stroke;
RUN;

PROC SGPLOT DATA=stroke_data;
    TITLE "Average Glucose Distribution & Outliers by Stroke Outcome";
    VBOX avg_glucose_level / GROUP=stroke;
RUN;

%macro bivariate_bar(var);

/* Frequency cross-tabulation with target variable */
PROC FREQ DATA=stroke_data NOPRINT;
    TABLES &var.*stroke / OUT=temp_&var;
RUN;

/* Calculate total observations per predictor category */
PROC MEANS DATA=temp_&var NOPRINT;
    CLASS &var;
    VAR count;
    OUTPUT OUT=totals_&var SUM(count)=total;
RUN;

/* Sort datasets before merging */
PROC SORT DATA=temp_&var; BY &var; RUN;
PROC SORT DATA=totals_&var; BY &var; RUN;

/* Merge counts with totals and compute proportions */
DATA prop_&var;
    MERGE temp_&var totals_&var;
    BY &var;

    prop = count/total;
RUN;

/* Visualize stroke distribution within each predictor group */
PROC SGPLOT DATA=prop_&var;
    TITLE "Stroke Distribution by &var";
    VBAR &var /
        RESPONSE=prop
        GROUP=stroke
        GROUPDISPLAY=stack;

    YAXIS LABEL="Proportion within &var";
RUN;

%mend;

%bivariate_bar(gender);
%bivariate_bar(ever_married);
%bivariate_bar(residence_type);
%bivariate_bar(smoking_status);
%bivariate_bar(hypertension);
%bivariate_bar(heart_disease);
%bivariate_bar(diabetes_cat);
%bivariate_bar(bmi_cat);

/* 3.2 Statistical tests */

/* Wilcoxon/Mann-Whitney for association:
   H0: Stochastic equality between stroke and non-stroke groups */
PROC NPAR1WAY DATA=stroke_data WILCOXON;
    CLASS stroke;
    VAR age bmi log_bmi avg_glucose_level;
RUN;

/* Chi-square tests for association:
   H0:  No association between predictor and outcome, that is 
   stroke outcome is independent of the predictor.*/
PROC FREQ DATA=stroke_data;
    TABLES gender*stroke / CHISQ;
    TABLES ever_married*stroke / CHISQ;
    TABLES residence_type*stroke / CHISQ;
    TABLES smoking_status*stroke / CHISQ;
    TABLES hypertension*stroke / CHISQ;
    TABLES heart_disease*stroke / CHISQ;
    TABLES diabetes_cat*stroke / CHISQ;
    TABLES bmi_cat*stroke / CHISQ;
RUN;

/************************************************************************** 
* SECTION 4: CHECK FOR MULTICOLLINEARITY 
**************************************************************************/ 
TITLE "Continuous-Continuous Multicolinearity"; 

/* Continuous-Continuous Variables Pearson for normal/linear Spearmen for skewed*/ 
PROC CORR DATA = stroke_data PEARSON SPEARMAN NOSIMPLE; 
	VAR age bmi avg_glucose_level; 
RUN; 

/* Categorical-Categorical */ 
TITLE "Categorical-Categorical Multicolinearity"; 
PROC FREQ DATA = stroke_data;
	TABLES gender*ever_married / CHISQ; 
	TABLES gender*residence_type / CHISQ; 
	TABLES gender*smoking_status / CHISQ; 
	TABLES gender*hypertension / CHISQ; 
	TABLES gender*heart_disease / CHISQ; 
	TABLES gender*diabetes_cat / CHISQ; 
	TABLES gender*bmi_cat / CHISQ; 
	
	TABLES ever_married*residence_type / CHISQ; 
	TABLES ever_married*smoking_status / CHISQ; 
	TABLES ever_married*hypertension / CHISQ; 
	TABLES ever_married*heart_disease / CHISQ; 
	TABLES ever_married*diabetes_cat / CHISQ; 
	TABLES ever_married*bmi_cat / CHISQ; 
	
	TABLES residence_type*smoking_status / CHISQ; 
	TABLES residence_type*hypertension / CHISQ; 
	TABLES residence_type*heart_disease / CHISQ; 
	TABLES residence_type*diabetes_cat / CHISQ; 
	TABLES residence_type*bmi_cat / CHISQ; 
	
	TABLES smoking_status*hypertension / CHISQ; 
	TABLES smoking_status*heart_disease / CHISQ; 
	TABLES smoking_status*diabetes_cat / CHISQ; 
	TABLES smoking_status*bmi_cat / CHISQ; 
	
	TABLES hypertension*heart_disease / CHISQ; 
	TABLES hypertension*diabetes_cat / CHISQ; 
	TABLES hypertension*bmi_cat / CHISQ; 
	TABLES heart_disease*diabetes_cat / CHISQ; 
	TABLES heart_disease*bmi_cat / CHISQ; 
	TABLES diabetes_cat*bmi_cat / CHISQ; 
RUN; 
	
TITLE "Continuous-Categorical Multicolinearity";
/* Continous-Binary */ 
PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS gender; 
	VAR age bmi avg_glucose_level; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS residence_type; 
	VAR age bmi avg_glucose_level; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS ever_married; 
	VAR age bmi avg_glucose_level; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS hypertension; 
	VAR age bmi avg_glucose_level; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS heart_disease; 
	VAR age bmi avg_glucose_level; 
RUN; 

/* Continuous-MultiCategory */ 
PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS smoking_status; 
	VAR age bmi avg_glucose_level; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS diabetes_cat; 
	VAR age bmi; 
RUN; 

PROC NPAR1WAY DATA = stroke_data WILCOXON; 
	CLASS bmi_cat; 
	VAR age avg_glucose_level; 
RUN;
