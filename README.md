# Diabetes Readmission Intelligence — SQL Analysis & Healthcare Dashboard

**Live Dashboard:** [View on Tableau Public](https://public.tableau.com/views/DiabetesPatientReadmissionAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

**Dataset:** 10 years of diabetic patient hospital records — 101,766 encounters across 130 US hospitals (1999–2008)

---

## Project Overview

Hospital readmissions within 30 days of discharge are one of the most closely watched metrics in healthcare. In the United States alone, preventable readmissions cost the healthcare system over $26 billion annually, and hospitals face direct financial penalties under Medicare when readmission rates exceed benchmarks.

This project analyses a decade of diabetic patient records to identify which patient groups carry the highest risk of early readmission — and why. The full pipeline runs from raw data ingestion and cleaning in MySQL, through exploratory analysis using SQL, to an interactive Tableau dashboard that translates clinical patterns into operational recommendations.

The goal is not just to describe the data but to answer a specific business question: where should hospital discharge teams focus their attention to prevent unnecessary readmissions?

---

## Dashboard Preview

![Diabetes Patient Readmission Dashboard](https://raw.githubusercontent.com/najeebullahii/Diabetes_Readmission_Analysis/main/03_Visualizations/dashboard_overview.png)

*The dashboard visualises readmission rates by age group, primary diagnosis category, and discharge disposition — the three factors most strongly associated with 30-day readmission risk.*

---

## Business Questions Answered

- Which patient age groups have the highest 30-day readmission rates?
- Does the primary diagnosis at admission predict the likelihood of readmission?
- Does the discharge destination — home, nursing facility, or home health agency — affect whether a patient returns within 30 days?
- What operational changes would have the greatest impact on reducing readmission rates?

---

## Key Findings

**1. Age is the strongest individual predictor**

Patients over the age of 70 showed the highest probability of 30-day readmission. This finding points directly to a gap in discharge planning for elderly patients — a group that frequently lacks the support infrastructure needed to manage post-discharge care independently.

**2. The primary driver of readmission is not diabetes**

Despite the dataset consisting entirely of diabetic patients, the leading diagnosis categories associated with readmission were Circulatory and Respiratory conditions — not diabetes itself. This is a critical insight for care teams: managing blood sugar alone is insufficient. Diabetic patients with comorbid heart or lung conditions require a different, more intensive discharge protocol.

**3. Discharge destination determines outcome**

Patients discharged to home without support had measurably higher readmission rates than those transferred to Skilled Nursing Facilities or placed under Home Health Agency care. The act of sending a high-risk patient home without structured follow-up is itself a risk factor.

---

## Recommendations

**Senior Check-In Protocol**
Implement a mandatory follow-up call within 48 hours for all patients over 70 discharged to home. This single intervention targets the highest-risk cohort directly.

**Comorbidity-Aware Discharge Instructions**
Develop specialised discharge documentation for diabetic patients who also present with Circulatory or Respiratory diagnoses. Standard diabetes management instructions are insufficient for this subgroup.

**Home Health Agency Expansion**
Increase referrals to Home Health Agencies for patients currently classified as Home (Self Care) discharge. The data shows that structured home support significantly reduces return visits.

---

## Data Cleaning & Transformation

All cleaning was performed in MySQL before analysis. The raw dataset contained several issues that required systematic resolution.

| Step | Issue | Resolution |
|---|---|---|
| Null handling | Missing values encoded as `?` | Standardised to NULL for accurate aggregation |
| Bias removal | Deceased and hospice patients included | Removed — these patients cannot be readmitted and would artificially deflate the readmission rate |
| Feature engineering | 700+ ICD-9 diagnosis codes | Grouped into 9 clinical categories: Circulatory, Respiratory, Diabetes, Digestive, Injury, Musculoskeletal, Genitourinary, Neoplasms, Other |
| Readmission labelling | Cryptic codes `<30`, `>30`, `NO` | Replaced with readable labels: Early Readmission, Late Readmission, No Readmission |
| Data quality | Weight column present | Dropped — over 90% of values missing, unusable for analysis |

The full SQL cleaning and transformation logic is available in the `02_SQL_Scripts` folder.

---

## Technical Challenges

The most technically demanding aspect of this project was the ICD-9 diagnosis code mapping. The raw dataset contains over 700 distinct diagnosis codes representing specific medical conditions at a granular clinical level. Presenting this directly in a dashboard would be meaningless to any non-medical audience.

The solution was to write a series of SQL CASE statements that mapped every code to one of nine high-level clinical categories based on ICD-9 code ranges. This required understanding the ICD-9 classification system, planning the logic carefully to avoid gaps or overlaps, and validating that the resulting categories were both clinically meaningful and analytically useful.

The end result — a clean nine-category breakdown — made the Tableau dashboard immediately interpretable by a general business audience without any medical background.

---

## Technology Stack

| Component | Technology |
|---|---|
| Data storage and querying | MySQL |
| Data cleaning and transformation | MySQL (ETL pipeline) |
| Exploratory data analysis | MySQL |
| Dashboard and visualisation | Tableau Desktop / Tableau Public |
| Version control | Git and GitHub |

---

## Repository Structure
```
Diabetes_Readmission_Analysis/
├── 01_Data/
│   ├── diabetic_data(raw).csv               # Original raw dataset from UCI
│   ├── cleaned_data.xlsb                    # Final cleaned dataset
│   ├── IDS_mapping.csv                      # ID reference mapping file
│   ├── admission_sources.csv                # Admission source reference table
│   ├── admission_types.csv                  # Admission type reference table
│   └── discharge_dispositions.csv           # Discharge destination reference table
├── 02_SQL_Scripts/
│   ├── Table Creation and Data Loading.sql  # Schema setup and data import
│   ├── Data Cleaning.sql                    # Null handling, bias removal, feature engineering
│   └── EDA queries.sql                      # Exploratory analysis queries
├── 03_Visualizations/
│   ├── dashboard_overview.png               # Dashboard screenshot
│   ├── Dashboard 1.pdf                      # Exported dashboard PDF
│   └── Diabetes Patient Readmission Analysis.twbx  # Tableau workbook
├── LICENSE
└── README.md
```

---

## Dataset

**Source:** UCI Machine Learning Repository — Diabetes 130-US Hospitals Dataset (1999–2008)

Beata Strack, Jonathan P. DeShazo, Chris Gennings, Juan L. Olmo, Sebastian Ventura, Krzysztof J. Cios, and John N. Clore. "Impact of HbA1c Measurement on Hospital Readmission Rates: Analysis of 70,000 Clinical Database Patient Records." BioMed Research International, 2014.

---

## Limitations

- The dataset covers 1999 to 2008 — clinical practices and readmission policies have changed significantly since then
- Only inpatient hospital encounters are included — outpatient follow-up data is absent
- The dataset does not include actual outcomes post-discharge, only whether the patient was readmitted
- Socioeconomic factors — insurance type, income level, geography — are not captured and likely influence readmission rates significantly

---

## License

MIT License — free to use and adapt for your own projects.
