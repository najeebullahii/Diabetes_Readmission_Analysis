-- Total number of records after cleaning
SELECT COUNT(*) AS total_records
FROM encounters_cleaned;

-- Quick look at table structure
DESCRIBE encounters_cleaned;
-- High-level view: What is the baseline readmission rate?
SELECT 
    readmission_status,
    COUNT(*) AS total_patients
FROM encounters_cleaned
GROUP BY readmission_status
ORDER BY total_patients DESC;

-- Examining Gender
SELECT 
    gender,
    COUNT(*) AS total_patients
FROM encounters_cleaned
GROUP BY gender
ORDER BY total_patients DESC;

-- Age Analysis: Do elderly patients have a higher risk of early return?
select 
    age,
    count(*) as total,
    sum(case when readmission_status = 'Readmitted within 30 days' then 1 else 0 end) as early_readmits,
    round(100.0 * sum(case when readmission_status = 'Readmitted within 30 days' then 1 else 0 end) / count(*), 1) as pct_early
from encounters_cleaned
group by age
order by pct_early desc;

-- Do patients who stay longer return more often?
-- Comparing the average length of stay across readmission categories.
SELECT
    readmission_status,
    ROUND(AVG(time_in_hospital), 2) AS avg_days_in_hospital
FROM encounters_cleaned
GROUP BY readmission_status
ORDER BY avg_days_in_hospital DESC;

-- Comparing Lab Tests and Medication Volume.
-- Higher numbers of lab tests usually indicate a more complex patient case.
SELECT
    readmission_status,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures
FROM encounters_cleaned
GROUP BY readmission_status;
SELECT
    readmission_status,
    ROUND(AVG(num_medications), 2) AS avg_medications
FROM encounters_cleaned
GROUP BY readmission_status;

-- Which organ systems are most involved in readmission?
-- First, look at the volume per category.
SELECT
    diag_1_category,
    COUNT(*) AS total_patients
FROM encounters_cleaned
GROUP BY diag_1_category
ORDER BY total_patients DESC;
SELECT
    diag_1_category,
    readmission_status,
    COUNT(*) AS total_patients
FROM encounters_cleaned
GROUP BY diag_1_category , readmission_status 
ORDER BY diag_1_category, readmission_status;

-- Diagnosis Risk: Which medical conditions are the most 'dangerous' for readmission? We look at the top 15 categories to ensure statistical significance.
with common_diags as (
    select diag_1_category
    from encounters_cleaned
    group by diag_1_category
    order by count(*) desc
    limit 15
)
select 
    diag_1_category,
    count(*) as total,
    round(100.0 * sum(case when readmission_status = 'Readmitted within 30 days' then 1 else 0 end) / count(*), 1) as pct_early_readmit
from encounters_cleaned
where diag_1_category in (select diag_1_category from common_diags)
group by diag_1_category
order by pct_early_readmit desc;

-- Does the length of stay correlate with readmission?
-- A longer stay might indicate a more severe case, but does it prevent readmission?
select 
    readmission_status,
    round(avg(time_in_hospital), 2) as avg_days,
    round(avg(num_medications), 2) as avg_meds,
    round(avg(number_diagnoses), 2) as avg_diags,
    round(avg(num_lab_procedures), 2) as avg_labs
from encounters_cleaned
group by readmission_status;

