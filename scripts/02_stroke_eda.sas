/**************************************************************************
* Program: 02_stroke_eda.sas
* Project: Healthcare Stroke Risk Analysis
* Author: Sophia L.
* Last Updated: 2026-07-17
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
	OUT = stroke_data
	/* first EDA iteration used ... /01_stroke_clean.csv */
	DATAFILE = "/home/u63931017/DataFiles/stroke_model.csv" 
	DBMS = CSV REPLACE;
	GETNAMES = yes;
	GUESSINGROWS = max;
RUN;

DATA stroke_data;
    SET stroke_data;

    IF stroke = "Yes" THEN stroke_num = 1;
    ELSE IF stroke = "No" THEN stroke_num = 0;
RUN;

DATA stroke_data_ordered;
    SET stroke_data;

    IF bmi_cat = "Underweight" THEN bmi_order = 1;
    ELSE IF bmi_cat = "Normal" THEN bmi_order = 2;
    ELSE IF bmi_cat = "Overweight" THEN bmi_order = 3;
    ELSE IF bmi_cat = "Obesity I" THEN bmi_order = 4;
    ELSE IF bmi_cat = "Obesity II" THEN bmi_order = 5;
    ELSE IF bmi_cat = "Obesity III" THEN bmi_order = 6;
RUN;

DATA stroke_data_ordered;
    SET stroke_data_ordered;

    IF diabetes_cat = "Normal" THEN diabetes_order = 1;
    ELSE IF diabetes_cat = "Prediabetes" THEN diabetes_order = 2;
    ELSE IF diabetes_cat = "Diabetes" THEN diabetes_order = 3;
RUN;

/**************************************************************************
* SECTION 2: UNIVARIATE ANALYSIS
**************************************************************************/

/* 2.1 DESCRIPTIVE STATISTICS */

PROC MEANS DATA = stroke_data n nmiss mean std min p25 median p75 max;
	VAR 
		age bmi log_bmi avg_glucose_level;
RUN;

PROC FREQ DATA = stroke_data;
	TABLES 
		gender ever_married residence_type smoking_status hypertension 
		heart_disease diabetes_cat bmi_cat stroke / MISSING;
RUN;

/* No missing (missing BMI imputed in 01_stroke_cleaning), 
	1 extraneous "other" gender */

/* Insight: Target variable distribution shows class imbalance */

/* 2.2 VISUAL ASSESSMENT*/

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Patient Age";
    HISTOGRAM age;
    DENSITY age;
    DENSITY age / TYPE = KERNEL LINEATTRS = (COLOR = red PATTERN = DASH);
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Body Mass Index (BMI)";
    HISTOGRAM bmi;
    DENSITY bmi;
    DENSITY bmi / TYPE = KERNEL LINEATTRS = (COLOR = red PATTERN = DASH);
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Logarithmic Body Mass Index (BMI)";
    HISTOGRAM log_bmi;
    DENSITY log_bmi;
    DENSITY log_bmi / TYPE = KERNEL LINEATTRS = (COLOR = red PATTERN = DASH);
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Average Glucose Levels (mg/dL)";
    HISTOGRAM avg_glucose_level;
    DENSITY avg_glucose_level;
    DENSITY avg_glucose_level / TYPE = KERNEL LINEATTRS = (COLOR = red PATTERN = DASH);
RUN;

%macro univariate_bar(var);

	PROC SGPLOT DATA = stroke_data;
    	TITLE "Frequency Distribution of %upcase($var)";
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
Insight:
	
   Age: Core values follow a normal pattern; heavy tails suggest outliers deviate
   BMI: Moderate right skew - therefore, a log-transformed version (log_bmi) was created 
   in the feature engineering stage and assessed for improved normality.
   Average Glucose: Clear non-normal pattern, bimodal - 
   		consider categorical representation of avg. glucose (diabetes_cat created in feature eng)*/

PROC UNIVARIATE DATA = stroke_data NORMAL;
    TITLE "Normality Tests for Continuous Variables";
    VAR age log_bmi bmi avg_glucose_level;
    QQPLOT age log_bmi bmi avg_glucose_level / NORMAL(MU = EST SIGMA = EST);
RUN;

/* 2.4 IDENTIFY POTENTIAL OUTLIERS 
Insight:

 Boxplots were used to identify potential outliers in age, BMI, and
 average glucose level. Although extreme BMI values
 (maximum BMI = 97.6) and extreme average glucose levels (max avg = 271.74) were observed.
 
 These records were retained because they are plausible clinical values 
 and reflect the right-skewed distributions rather than obvious data-entry errors.
*/

PROC SGPLOT DATA = stroke_data; 
    TITLE "Age Distribution & Outliers";
    VBOX age;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "BMI Distribution & Outliers";
    VBOX bmi;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Log(BMI) Distribution & Outliers";
    VBOX log_bmi;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Average Glucose Distribution & Outliers";
    VBOX avg_glucose_level;
RUN;

/**************************************************************************
* SECTION 3: BIVARIATE ANALYSIS WITH STROKE OUTCOME 
**************************************************************************/

/* 3.1 VISUAL ASSESSMENT */

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Patient Age by Stroke Outcome";
    HISTOGRAM age / GROUP = stroke TRANSPARENCY = 0.5;
    DENSITY age;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Body Mass Index (BMI) by Stroke Outcome";
    HISTOGRAM bmi / GROUP = stroke TRANSPARENCY = 0.5;
    DENSITY bmi;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Logarithmic Body Mass Index (BMI) by Stroke Outcome";
    HISTOGRAM log_bmi / GROUP = stroke TRANSPARENCY = 0.5;
    DENSITY log_bmi;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Distribution of Average Glucose Levels (mg/dL) by Stroke Outcome";
    HISTOGRAM avg_glucose_level / GROUP = stroke TRANSPARENCY = 0.5;
    DENSITY avg_glucose_level;
RUN;

PROC SGPLOT DATA = stroke_data; 
    TITLE "Age Distribution & Outliers by Stroke Outcome";
    VBOX age / GROUP = stroke;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "BMI Distribution & Outliers by Stroke Outcome";
    VBOX bmi / GROUP = stroke;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Log(BMI) Distribution & Outliers by Stroke Outcome";
    VBOX log_bmi / GROUP = stroke;
RUN;

PROC SGPLOT DATA = stroke_data;
    TITLE "Average Glucose Distribution & Outliers by Stroke Outcome";
    VBOX avg_glucose_level / GROUP = stroke;
RUN;

%macro bivariate_bar(var);

	/* Frequency cross-tabulation with target variable */
	PROC FREQ DATA = stroke_data NOPRINT;
    	TABLES &var.*stroke / OUT = temp_&var;
	RUN;

	/* Calculate total observations per predictor category */
	PROC MEANS DATA = temp_&var NOPRINT;
    	CLASS &var;
    	VAR count;
    	OUTPUT OUT = totals_&var SUM(count) = total;
	RUN;

	/* Sort datasets before merging */
	PROC SORT DATA = temp_&var; BY &var; RUN;
	PROC SORT DATA = totals_&var; BY &var; RUN;

	/* Merge counts with totals and compute proportions */
	DATA prop_&var;
    	MERGE temp_&var totals_&var;
    	BY &var;

    	prop = count/total;
	RUN;

	/* Visualize stroke distribution within each predictor group */
	PROC SGPLOT DATA = prop_&var;
    	TITLE "Stroke Distribution by &var";
    	VBAR &var /
        	RESPONSE = prop
        	GROUP = stroke
        	GROUPDISPLAY = stack;

    	YAXIS LABEL = "Proportion within %upcase(&var)";
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
ODS SELECT WilcoxonScores WilcoxonTest;
TITLE "Continuous Variables*Stroke";
PROC NPAR1WAY DATA = stroke_data WILCOXON;
    CLASS stroke;
    VAR age bmi log_bmi avg_glucose_level;
RUN;

/* Insight: 
	Effect sizes were approximated using r = Z / sqrt(N).

	- Age shows a small-to-moderate effect (r ≈ 0.25)
	- Glucose shows a small effect (r ≈ 0.08)
	- BMI shows a very small effect (r ≈ 0.05) 
*/

/* Chi-square tests for association:
   H0:  No association between predictor and outcome, that is 
   stroke outcome is independent of the predictor.*/
ODS SELECT ChiSq;
TITLE "Categorical Variables*Stroke";
PROC FREQ DATA = stroke_data;
	WHERE gender ne "Other";
	TABLES gender*stroke / CHISQ;
RUN;

PROC FREQ DATA = stroke_data;
	TABLES
	    ever_married*stroke
	    residence_type*stroke
	    smoking_status*stroke
	    hypertension*stroke
	    heart_disease*stroke
	    diabetes_cat*stroke
    	bmi_cat*stroke / CHISQ;
RUN;

/* 3.3 Feature Representation Assessment */

/* BMI - Evaluating the raw BMI original continuous measurement, 
   log(BMI) created to address right-skewness,
   and BMI categories apply WHO clinical thresholds to capture nonlinear risk patterns. */
  
PROC SORT DATA = stroke_data_ordered;
    BY bmi_order;
RUN;

PROC SGPLOT DATA = stroke_data_ordered;
    TITLE "Stroke Rate Across BMI Categories";
    VBAR bmi_cat /
        RESPONSE = stroke_num
        STAT = MEAN;
    
    XAXIS DISCRETEORDER=data FITPOLICY=stagger;
    YAXIS LABEL = "Stroke Proportion";
RUN;


PROC SGPLOT DATA = stroke_data;
    TITLE "Relationship Between BMI and Stroke Outcome";
    VBOX bmi / GROUP = stroke;
RUN;


PROC SGPLOT DATA = stroke_data;
    TITLE "Relationship Between Log(BMI) and Stroke Outcome";
    VBOX log_bmi / GROUP = stroke;
RUN;

OPTIONS LINESIZE = 180;
PROC FREQ DATA = stroke_data_ordered ORDER = data;
    TABLES bmi_cat*stroke;
RUN;

/* Glucose - Evaluate raw glucose original continuous measurement,
   and diabetes categories to provide clinically interpretable results. */

PROC SORT DATA = stroke_data_ordered;
    BY diabetes_order;
RUN;

Proc SGPLOT DATA = stroke_data;
    TITLE "Stroke Rate Across Diabetes Categories";
    VBAR diabetes_cat /
        RESPONSE = stroke_num
        STAT = MEAN;

    XAXIS DISCRETEORDER=data FITPOLICY=stagger;
    YAXIS LABEL = "Stroke Proportion";
RUN;


PROC SGPLOT DATA = stroke_data;
    TITLE "Relationship Between Average Glucose and Stroke Outcome";
    VBOX avg_glucose_level / GROUP = stroke;
RUN;

PROC FREQ DATA = stroke_data_ordered ORDER = data;
    TABLES diabetes_cat*stroke;
RUN;


/************************************************************************** 
* SECTION 4: CHECK FOR MULTICOLLINEARITY 
**************************************************************************/ 
TITLE "Continuous-Continuous Multicolinearity"; 
PROC SGSCATTER DATA = stroke_data;
	MATRIX age bmi log_bmi avg_glucose_level / DIAGONAL = (histogram KERNEL NORMAL);
RUN;


/* Continuous-Continuous Variables Pearson for normal/linear Spearmen for skewed*/ 
ODS OUTPUT SpearmanCorr = MySpearmanMatrix;
PROC CORR DATA = stroke_data SPEARMAN NOSIMPLE; 
	VAR age bmi avg_glucose_level; 
RUN; 

DATA HeatMapData;
	SET MySpearmanMatrix(RENAME = (variable = RowName));
	ARRAY cols[*] age bmi avg_glucose_level;
	DO i = 1 to dim(cols);
		ColName = vname(cols[i]);
		Correlation = cols[i];
		CorrLabel = put(cols[i], 8.2);
		IF Correlation ne . THEN OUTPUT; 
	END;
	KEEP RowName ColName Correlation CorrLabel;
RUN;

PROC SGPLOT DATA = HeatMapData;
	HEATMAPPARM X = ColName Y = RowName COLORRESPONSE = Correlation
	/ NAME = "heatmap";
	TEXT X = ColName Y = RowName TEXT = CorrLabel
	/ POSITION = center;
	GRADLEGEND "heatmap" / title = "Spearman Rank Correlation ($\rho$)";
RUN;

/* Categorical-Categorical */ 
TITLE "Categorical-Categorical Multicolinearity"; 
ODS SELECT ChiSq;
TITLE "Categorical-Categorical Multicolinearity"; 
PROC FREQ DATA = stroke_data;
	WHERE gender ne "Other";
	TABLES 
		gender*ever_married 
		gender*residence_type 
	 	gender*smoking_status 
		gender*hypertension
	 	gender*heart_disease 
	 	gender*diabetes_cat 
	 	gender*bmi_cat / CHISQ;
RUN;

PROC FREQ DATA = stroke_data;
	 TABLES
	 	ever_married*residence_type  
	 	ever_married*smoking_status  
	 	ever_married*hypertension 
	 	ever_married*heart_disease 
	 	ever_married*diabetes_cat 
	 	ever_married*bmi_cat 
	
	 	residence_type*smoking_status  
	 	residence_type*hypertension 
	 	residence_type*heart_disease 
	 	residence_type*diabetes_cat  
	 	residence_type*bmi_cat 
	
	 	smoking_status*hypertension  
	 	smoking_status*heart_disease  
	 	smoking_status*diabetes_cat  
	 	smoking_status*bmi_cat 
	
	 	hypertension*heart_disease 
	 	hypertension*diabetes_cat 
	 	hypertension*bmi_cat 
	 	
	 	heart_disease*diabetes_cat  
	 	heart_disease*bmi_cat  
	 
	 	diabetes_cat*bmi_cat / CHISQ; 
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

/************************************************************************** 
* SECTION 5: KEY EDA INSIGHTS
**************************************************************************/

/*
1. DATA OVERVIEW + SUMMARY STATISTICS

Target Variable
	- Stroke outcome is highly imbalanced (<5% positive cases)

Continuous Variable Summaries: 
	- Age: mean = 43.2, stddev = 22.6, min = 0.08, med = 45, max = 82
	- BMI: mean = 28.9, stddev = 7.7, min = 10.3, med = 28.1, max = 97.6
	- Glucose: mean = 106.1, stddev = 45.3, min = 55.1, med = 91.9, max = 271.7

Categorical Variable Summaries:
	- Gender: 58.6% F, 41.4% M
	- Married?: 34.3% No, 65.6% Yes
	- Residence: 49.2% Rural, 50.8 Urban
	- Smoking Status: 37.0% Never, 30.2% Unknown, 17.3% former, 15.4% current
	- Hypertension: 90.3% No, 9.7% Yes
	- Heart Disease: 94.6% No, 5.4% Yes
	- Diabetes (created from avg_glucose_level): 76.9% Normal, 13.8% Diabetic, 9.3% Prediabetes
	- BMI (created from numeric BMI): 31.5% Overweight, 24.3% Normal, 19.6% Obesity I, 9.9% Obesity II, 8.1% Severe, 6.7% Underweight
*/

/* 
2. UNIVARIATE DISTRIBUTIONS

Age: Histogram and Skewness value indicate a slight left skew, but approximately normal (no transformation needed)
	 Outliers in the lower and upper ranges of age deviate from normality; but are retained as there are no signs of data entry errors.
	 
BMI: Histogram and Skewness value indicate a substantial positive skew.
	 Log(BMI) Improves symmetry and reduces skewnesses compared to raw BMI.

Glucose: Histogram and Skewness value indicate a non-normal, bimodal distribution.
		 This suggests distinct patient groups to improve modeling.
		 
Categorical frequencies not reported for brevity, see 1. DATA OVERVIEW + SUMMARY STATISTICS 
*/

/* 
3. BIVARIATE RELATIONSHIP WITH STROKE

Continuous Variables (Wilcoxon/Mann-Whitney Test):
	- Age shows a strong separation between stroke and non-stroke groups with a moderate effect size.
	- Average glucose shows a statistically significant association with stroke, but a small effect size.
	- BMI and log(BMI) show a statistically significant relationship with stroke, but a weak effect size.

Categorical Variables (Chi-square Test):
	-Significant observations observed for:
		*Ever married (small-weak association) - likely a proxy for age
		*Smoking status (weaker association)
		*Hypertension (small-weak association)
		*Heart Disease (small-weak association)
		*Diabetes Category (small-weak association)
		*BMI Category (weaker association)
	
	-Non-significant:
		*Gender
		*Residence Type
*/

/*
4. MULTICOLLINEARITY AND VARIABLE RELATIONSHIPS
Key Findings:

	- Age is a central variable, showing moderate associations with BMI 
	  and strong association with ever_married, suggesting that marital status likely acts as a proxy for age.

	- No meaningful relationships were observed between residence type and other variables, indicating limited relevance for stroke prediction.
	  Somewhat unexpected given known urban-rural health disparities.
	 
	- Gender is not a significant predictor of stroke, but its associations with key predictors (e.g., age, BMI) suggest potential effect modification, 
	  warranting consideration of stratified or interaction analyses.
	  
	- Smoking status shows a moderate association with BMI, indicating potential clustering of lifestyle-related risk factors.
	
	- Hypertension and heart disease are both moderately associated with age, reinforcing age as a primary driver of cardiovascular risk.
	
	- No strong signal of multicollinearity/redundancy (other than marital status-age)
*/
