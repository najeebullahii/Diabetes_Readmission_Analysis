-- Created a dedicated 'cleaned' table to preserve the original raw data
CREATE TABLE encounters_cleaned AS
SELECT *
FROM encounters;

-- Standardizing '?' as NULLs across critical columns
UPDATE encounters_cleaned
SET
    race = NULLIF(race, '?'),
    weight = NULLIF(weight, '?'),
    payer_code = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    diag_1 = NULLIF(diag_1, '?'),
    diag_2 = NULLIF(diag_2, '?'),
    diag_3 = NULLIF(diag_3, '?');
    
-- Dropping the Weight column as it is over 90% missing and would skew any predictive analysis.
ALTER TABLE encounters_cleaned
DROP COLUMN weight;

-- Creating a clear 'Readmission Status' label instead of symbols like <30, we use descriptive text for Tableau stakeholders.
ALTER TABLE encounters_cleaned
ADD readmission_status VARCHAR(25);
UPDATE encounters_cleaned
SET readmission_status =
    CASE
        WHEN readmitted = '<30' THEN 'Readmitted within 30 days'
        WHEN readmitted = '>30' THEN 'Readmitted after 30 days'
        ELSE 'Not readmitted'
    END;

-- Removing patients who passed away or entered hospice.
-- Because these patients physically cannot be readmitted, and keeping them would artificially lower our readmission rates.
DELETE FROM encounters_cleaned
WHERE discharge_disposition_id IN (11, 13, 14, 19, 20, 21);
DELETE FROM encounters_cleaned
WHERE gender = 'Unknown/Invalid';

-- Joining reference tables to get descriptive names for IDs
ALTER TABLE encounters_cleaned
ADD COLUMN admission_type_desc VARCHAR(100),
ADD COLUMN discharge_disposition_desc VARCHAR(200),
ADD COLUMN admission_source_desc VARCHAR(100);

-- Maping admission_types
UPDATE encounters_cleaned e
JOIN admission_types a ON e.admission_type_id = a.id
SET e.admission_type_desc = a.description;

-- Maping discharge_disposition_id
UPDATE encounters_cleaned e
JOIN discharge_dispositions d ON e.discharge_disposition_id = d.id
SET e.discharge_disposition_desc = d.description;

-- Maping admission_source_id
UPDATE encounters_cleaned e
JOIN admission_sources s ON e.admission_source_id = s.id
SET e.admission_source_desc = s.description;

-- Quick check to see if it worked
SELECT 
    admission_type_id, admission_type_desc,
    discharge_disposition_id, discharge_disposition_desc,
    admission_source_id, admission_source_desc
FROM encounters_cleaned
LIMIT 10;

-- Grouping ICD-9 Codes
-- Medical codes are too granular. Grouping them into 'Circulatory', 'Respiratory', etc.
ALTER TABLE encounters_cleaned
ADD diag_1_category VARCHAR(50),
ADD diag_2_category VARCHAR(50),
ADD diag_3_category VARCHAR(50);

UPDATE encounters_cleaned
SET diag_1_category =
    CASE
    WHEN diag_1 IS NULL OR diag_1 = '' OR diag_1 = '?' THEN 'Missing'
    WHEN diag_1 LIKE 'V%' THEN 'Supplementary factors'
    WHEN diag_1 LIKE 'E%' THEN 'External Causes'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 1   AND 139 THEN 'Infectious Diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239 THEN 'Neoplasms'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279 THEN 'Endocrine'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289 THEN 'Blood diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319 THEN 'Mental Disorders'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389 THEN 'Nervous System'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory System'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory System'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive System'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679 THEN 'Pregnancy/childbirth'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709 THEN 'Skin'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739 THEN 'Musculoskeletal'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759 THEN 'Congenital Anomalies'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779 THEN 'Perinatal'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799 THEN 'Symptoms / Unspecified'
    WHEN CAST(SUBSTRING_INDEX(diag_1, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury/Poisoning'
    ELSE 'Other'
END;

UPDATE encounters_cleaned 
SET diag_2_category = 
CASE
    WHEN diag_2 IS NULL OR diag_2 = '' OR diag_2 = '?' THEN 'Missing'
    WHEN diag_2 LIKE 'V%' THEN 'Supplementary factors'
    WHEN diag_2 LIKE 'E%' THEN 'External Causes'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 1   AND 139 THEN 'Infectious Diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239 THEN 'Neoplasms'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279 THEN 'Endocrine'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289 THEN 'Blood diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319 THEN 'Mental Disorders'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389 THEN 'Nervous System'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory System'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory System'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive System'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679 THEN 'Pregnancy/childbirth'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709 THEN 'Skin'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739 THEN 'Musculoskeletal'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759 THEN 'Congenital Anomalies'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779 THEN 'Perinatal'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799 THEN 'Symptoms / Unspecified'
    WHEN CAST(SUBSTRING_INDEX(diag_2, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury/Poisoning'
    ELSE 'Other'
END;


UPDATE encounters_cleaned 
SET diag_3_category = 
CASE
    WHEN diag_3 IS NULL OR diag_3 = '' OR diag_3 = '?' THEN 'Missing'
    WHEN diag_3 LIKE 'V%' THEN 'Supplementary factors'
    WHEN diag_3 LIKE 'E%' THEN 'External Causes'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 1   AND 139 THEN 'Infectious Diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 140 AND 239 THEN 'Neoplasms'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 240 AND 279 THEN 'Endocrine'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 280 AND 289 THEN 'Blood diseases'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 290 AND 319 THEN 'Mental Disorders'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 320 AND 389 THEN 'Nervous System'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory System'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory System'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive System'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 630 AND 679 THEN 'Pregnancy/childbirth'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 680 AND 709 THEN 'Skin'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 710 AND 739 THEN 'Musculoskeletal'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 740 AND 759 THEN 'Congenital Anomalies'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 760 AND 779 THEN 'Perinatal'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 780 AND 799 THEN 'Symptoms / Unspecified'
    WHEN CAST(SUBSTRING_INDEX(diag_3, '.', 1) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury/Poisoning'
    ELSE 'Other'
END;

UPDATE encounters_cleaned
SET payer_code = 'Missing'
WHERE payer_code IS NULL;

-- Row count comparison
SELECT 
    (SELECT COUNT(*) FROM encounters) AS raw_rows,
    (SELECT COUNT(*) FROM encounters_cleaned) AS cleaned_rows;
    