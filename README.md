# 🏥 Hospital Readmission Analysis (Diabetes Patients)

## 📄 Project Overview
In healthcare system, hospital readmissions—specifically those occurring within 30 days of discharge are a primary performance metric. High readmission rates cost hospitals millions in penalties and indicate gaps in patient care. 

This project analyzes a dataset of **10+ years of hospital records** (Diabetes dataset) to identify the root causes of early readmissions. By cleaning the raw data in MySQL and visualizing trends in Tableau, I uncovered patterns related to patient age, medical specialty, and discharge procedures.

**Goal:** To determine which patient groups are at the highest risk of being readmitted within 30 days and propose data-driven strategies to reduce this rate.

---

## 📊 Live Dashboard
👉 **[Click here to view the Interactive Tableau Dashboard](https://public.tableau.com/views/DiabetesPatientReadmissionAnalysis/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)** *Explore the readmission rates by age, gender, and medical diagnosis.*

---

## 🛠 Tools & Technologies
* **MySQL:** Used for ETL (Extract, Transform, Load), comprehensive data cleaning, and Exploratory Data Analysis (EDA).
* **Tableau:** Used to build the interactive dashboard.

---

## 🔍 Data Cleaning & Transformation (SQL)
Raw healthcare data is messy. I performed extensive cleaning in MySQL before beginning the analysis.

**Key Steps Taken:**
1.  **Null Handling:** Standardized missing values (originally marked as `?`) to `NULL` for accurate calculation.
2.  **Bias Removal:** Removed records for patients who were discharged to hospice or passed away. Including these would skew the readmission rate calculation, as these patients physically cannot return to the hospital.
3.  **Feature Engineering:** * Grouped over 700 specific **ICD-9 diagnosis codes** into 9 high-level categories (e.g., *Circulatory*, *Respiratory*, *Diabetes*) to make the data understandable for non-medical stakeholders.
    * Created a readable `Readmission Status` column to replace cryptic codes like `<30` and `>30`.
4.  **Data Quality:** Dropped the `Weight` column as it had >90% missing values.

*You can view the full cleaning logic in the `02_SQL_Scripts` folder.*

---

## 💡 Key Insights
After analyzing the clean data, three major risk factors emerged:

### 1. Age is a Determining Factor
Patients over the age of **70** showed the highest probability of being readmitted within 30 days. This trend suggests that discharge planning for seniors needs to be more robust, potentially involving mandatory home health coordination.

### 2. Diagnosis Drivers
Surprisingly, while the patients were diabetic, the primary reason for readmission was often **Circulatory** (Heart) or **Respiratory** (Lung) issues.
* *Insight:* Diabetes management programs should include stricter monitoring of heart and lung health to prevent return visits.

### 3. Discharge Disposition
Patients discharged to their **home** (without support) had higher readmission rates compared to those transferred to Skilled Nursing Facilities (SNF) or those receiving Home Health Agency support.

---

## 📈 Recommendations
Based on these findings, I recommend the following operational changes:
1.  **Senior "Check-In" Protocol:** Implement a mandatory follow-up call within 48 hours for all discharged patients over 70.
2.  **Comorbidity Education:** Provide specialized discharge instructions for diabetic patients who also suffer from Circulatory or Respiratory issues.
3.  **Home Health Utilization:** Increase the use of Home Health Agencies for patients currently scheduled to be discharged to "Home (Self Care)".

---

## 📂 Repository Structure
* `01_Data`: Contains the cleaned CSV dataset and ID mapping files.
* `02_SQL_Scripts`: Contains the ordered SQL queries used for table creation, cleaning, and analysis.