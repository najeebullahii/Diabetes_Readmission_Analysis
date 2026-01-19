CREATE DATABASE IF NOT EXISTS hospital_readmissions;
USE hospital_readmissions;
-- Defining the primary table structure
CREATE TABLE encounters (
    encounter_id BIGINT PRIMARY KEY,  
    patient_nbr BIGINT NOT NULL,       
    race VARCHAR(50),                  
    gender VARCHAR(50),                
    age VARCHAR(10),                   
    weight VARCHAR(10),                
    admission_type_id INT,             
    discharge_disposition_id INT,      
    admission_source_id INT,           
    time_in_hospital INT,              
    payer_code VARCHAR(10),            
    medical_specialty VARCHAR(100),    
    num_lab_procedures INT,            
    num_procedures INT,                
    num_medications INT,               
    number_outpatient INT,             
    number_emergency INT,              
    number_inpatient INT,              
    diag_1 VARCHAR(10),                
    diag_2 VARCHAR(10),                
    diag_3 VARCHAR(10),                
    number_diagnoses INT,              
    max_glu_serum ENUM('None', 'Norm', '>200', '>300'),  
    A1Cresult ENUM('None', 'Norm', '>7', '>8'),         
    metformin ENUM('No', 'Steady', 'Up', 'Down'),       
    repaglinide ENUM('No', 'Steady', 'Up', 'Down'),
    nateglinide ENUM('No', 'Steady', 'Up', 'Down'),
    chlorpropamide ENUM('No', 'Steady', 'Up', 'Down'),
    glimepiride ENUM('No', 'Steady', 'Up', 'Down'),
    acetohexamide ENUM('No', 'Steady', 'Up', 'Down'),
    glipizide ENUM('No', 'Steady', 'Up', 'Down'),
    glyburide ENUM('No', 'Steady', 'Up', 'Down'),
    tolbutamide ENUM('No', 'Steady', 'Up', 'Down'),
    pioglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    rosiglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    acarbose ENUM('No', 'Steady', 'Up', 'Down'),
    miglitol ENUM('No', 'Steady', 'Up', 'Down'),
    troglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    tolazamide ENUM('No', 'Steady', 'Up', 'Down'),
    examide ENUM('No', 'Steady', 'Up', 'Down'),        
    citoglipton ENUM('No', 'Steady', 'Up', 'Down'),    
    insulin ENUM('No', 'Steady', 'Up', 'Down'),
    glyburide_metformin ENUM('No', 'Steady', 'Up', 'Down'),
    glipizide_metformin ENUM('No', 'Steady', 'Up', 'Down'),
    glimepiride_pioglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    metformin_rosiglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    metformin_pioglitazone ENUM('No', 'Steady', 'Up', 'Down'),
    `change` ENUM('No', 'Ch'),                         -- Escaped with backticks!
    diabetesMed ENUM('No', 'Yes'),                     
    readmitted ENUM('NO', '>30', '<30')                
);
CREATE TABLE admission_types (
    id INT PRIMARY KEY,
    description VARCHAR(100)
);

CREATE TABLE discharge_dispositions (
    id INT PRIMARY KEY,
    description VARCHAR(200)  -- Longer desc like "Expired at home..."
);
CREATE TABLE admission_sources (
    id INT PRIMARY KEY,
    description VARCHAR(100)
);
ALTER TABLE encounters
ADD FOREIGN KEY (admission_type_id) REFERENCES admission_types(id),
ADD FOREIGN KEY (discharge_disposition_id) REFERENCES discharge_dispositions(id),
ADD FOREIGN KEY (admission_source_id) REFERENCES admission_sources(id);

-- LOADING DATA: Replaced the '?' with NULLs during ingestion to make future calculations and filtering much easier.
LOAD DATA LOCAL INFILE 
'C:/Users/Najib/Documents/Custom Office Templates/diabetic_data.csv'
INTO TABLE encounters
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    encounter_id, patient_nbr, race, gender, age, weight, admission_type_id,
    discharge_disposition_id, admission_source_id, time_in_hospital, payer_code,
    medical_specialty, num_lab_procedures, num_procedures, num_medications,
    number_outpatient, number_emergency, number_inpatient, diag_1, diag_2, diag_3,
    number_diagnoses, max_glu_serum, A1Cresult, metformin, repaglinide, nateglinide,
    chlorpropamide, glimepiride, acetohexamide, glipizide, glyburide, tolbutamide,
    pioglitazone, rosiglitazone, acarbose, miglitol, troglitazone, tolazamide,
    examide, citoglipton, insulin, glyburide_metformin, glipizide_metformin,
    glimepiride_pioglitazone, metformin_rosiglitazone, metformin_pioglitazone,
    `change`, diabetesMed, readmitted
)
-- column mapping
SET
    weight = NULLIF(weight, '?'),
    payer_code = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    race = NULLIF(race, '?'),
    diag_1 = NULLIF(diag_1, '?'),
    diag_2 = NULLIF(diag_2, '?'),
    diag_3 = NULLIF(diag_3, '?');
