# Diabetes Readmission Intelligence — SQL Analysis & Healthcare Dashboard

**Live Dashboard:** [View on Tableau Public](https://public.tableau.com/views/DiabetesPatientReadmissionAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

**Dataset:** 10 years of diabetic patient hospital records — 101,766 encounters across 130 US hospitals (1999–2008)

## What This Project Is About

Hospital readmissions are expensive, preventable, and a direct signal that something went wrong in the discharge process. In the US, hospitals face financial penalties from Medicare when their readmission rates exceed national benchmarks which means this is not just a clinical problem, it is a business problem too.

I took a decade of diabetic patient records from 130 US hospitals and used MySQL to clean the data, run exploratory analysis, and build a Tableau dashboard that answers one specific question: which patients are most likely to come back within 30 days, and what can the hospital actually do about it?

The dataset covers 101,766 patient encounters between 1999 and 2008. It is messy, medically complex, and exactly the kind of data that looks intimidating until you build a system for handling it.

## Dashboard Preview

![Diabetes Patient Readmission Dashboard](https://raw.githubusercontent.com/najeebullahii/Diabetes_Readmission_Analysis/main/03_Visualizations/dashboard_overview.png)

*The dashboard breaks down readmission rates by age group, primary diagnosis category, and discharge destination, the three factors that consistently showed the strongest relationship with early readmission.*

## What I Found

**Age matters more than the diagnosis itself.** Patients over 70 had the highest 30-day readmission rates by a clear margin. This group often lacks the support system needed to follow discharge instructions properly, and the data reflects that.

**The diabetes label is misleading.** The dataset is entirely diabetic patients, so you would expect diabetes-related complications to drive most readmissions. They do not. Circulatory and Respiratory conditions were the primary diagnosis categories associated with early readmission. For care teams, this means that managing blood sugar alone is not enough, diabetic patients who also have heart or lung conditions need a completely different discharge protocol.

**Where you send a patient after discharge determines whether they come back.** Patients discharged to home without any follow-up support had measurably higher readmission rates than those transferred to Skilled Nursing Facilities or connected with a Home Health Agency. The discharge destination is not just an administrative decision it is a clinical one.

## Recommendations

**Senior Check-In Protocol.** A mandatory follow-up call within 48 hours for all patients over 70 discharged to home would directly target the highest-risk group. This does not require new infrastructure just a structured process.

**Comorbidity-Aware Discharge Instructions.** Standard diabetes management handouts are not sufficient for patients who also present with circulatory or respiratory diagnoses. This subgroup needs specialised documentation that addresses the conditions actually driving their readmissions.

**Home Health Agency Expansion.** The data shows a clear difference in outcomes between patients who receive structured home support and those who do not. Increasing referrals to Home Health Agencies for patients currently classified as Home (Self Care) discharge is a direct, evidence-based intervention.

## Data Cleaning and Transformation

All cleaning was done in MySQL before any analysis began. The raw dataset had several problems that needed to be resolved systematically before it was usable.

| Step | Issue | Resolution |
|---|---|---|
| Null handling | Missing values encoded as `?` | Standardised to NULL for accurate aggregation |
| Bias removal | Deceased and hospice patients included | Removed — these patients cannot be readmitted and their inclusion would artificially lower the readmission rate |
| Feature engineering | 700+ ICD-9 diagnosis codes | Grouped into 9 clinical categories: Circulatory, Respiratory, Diabetes, Digestive, Injury, Musculoskeletal, Genitourinary, Neoplasms, Other |
| Readmission labelling | Cryptic codes `<30`, `>30`, `NO` | Replaced with readable labels: Early Readmission, Late Readmission, No Readmission |
| Data quality | Weight column present | Dropped — over 90% of values were missing |

The full SQL logic is in the `02_SQL_Scripts` folder.

## The ICD-9 Problem

The most technically demanding part of this project was the diagnosis code mapping. The raw dataset contains over 700 distinct ICD-9 codes representing specific medical conditions at a level of granularity that is meaningless to anyone without a clinical background.

The solution was a series of SQL CASE statements that mapped every code to one of nine high-level categories based on ICD-9 numeric ranges. This required understanding how the ICD-9 classification system is structured, planning the logic to avoid gaps or overlaps between categories, and validating that the groupings were both clinically defensible and analytically meaningful.

It took longer than any other single step in the project, but it is what made the final dashboard readable to a non-medical audience.

## Technology Stack

| Component | Technology |
|---|---|
| Data storage and querying | MySQL |
| Data cleaning and transformation | MySQL (ETL pipeline) |
| Exploratory data analysis | MySQL |
| Dashboard and visualisation | Tableau Desktop and Tableau Public |
| Version control | Git and GitHub |

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

## Dataset

UCI Machine Learning Repository — Diabetes 130-US Hospitals Dataset (1999–2008)

Strack et al. "Impact of HbA1c Measurement on Hospital Readmission Rates: Analysis of 70,000 Clinical Database Patient Records." BioMed Research International, 2014.

## Limitations

The dataset covers 1999 to 2008, which means clinical practices and readmission policies have changed significantly since this data was collected. Only inpatient encounters are included, there is no outpatient follow-up data, which limits what can be said about post-discharge outcomes. Socioeconomic factors like insurance type, income level, and geography are not captured but almost certainly influence readmission rates in ways the model cannot see.

## License

MIT License — free to use and adapt for your own projects.
