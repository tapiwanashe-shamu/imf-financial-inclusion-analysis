-- DATA CLEANING PROCESS
-- 1. Create staging table, with columns from source table (imf_financial_access_table)
CREATE TABLE imf_staging_table
LIKE imf_financial_access_table;

-- 2. Insert raw data from source table (imf_financial_access_table) into staging table (imf_staging_table)
INSERT imf_staging_table
SELECT *
FROM imf_financial_access_table;

-- 3a. Using a CTE and Window Function to search for duplicates
WITH imf_ranked_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY SERIES_CODE
) as rank_number
FROM imf_staging_table
)
SELECT *
FROM imf_ranked_cte
WHERE rank_number > 1
;

-- 3a. Create a new table (imf_table_cleaned) with row_number column 
CREATE TABLE imf_table_cleaned
LIKE imf_staging_table;
ALTER TABLE imf_table_cleaned
ADD COLUMN `rank_number` INT;

-- 3b. Copy data from imf_staging_table to imf_table_cleaned, then remove duplicates using a Window Function
INSERT INTO imf_table_cleaned
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY SERIES_CODE
) as rank_number
FROM imf_staging_table
;

DELETE 
FROM imf_table_cleaned
WHERE rank_number > 1
;

-- 4. AI-Generated Query that outputs batch text of all the columns that should be dropped in imf_table_cleaned, to increase efficiency.
SELECT CONCAT(
'ALTER TABLE imf_table_cleaned DROP COLUMN `',
`COLUMN_NAME`,
'`;'
) AS columns_to_drop
FROM INFORMATION_SCHEMA.COLUMNS
WHERE `TABLE_SCHEMA` = 'data_portfolio_projects'
AND `TABLE_NAME` = 'imf_table_cleaned'
AND `COLUMN_NAME` NOT IN (
'SERIES_CODE', 'COUNTRY', 'FA_INDICATORS', 'TYPE_OF_TRANSFORMATION','SCALE', 
'COUNTERPART_SECTOR', 'SERIES_NAME',
'2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014',
'2015','2016','2017','2018','2019','2020','2021','2021','2022','2023','2024'
)
;

-- 5. Drop All columns provided in step 4
ALTER TABLE imf_table_cleaned DROP COLUMN `ACCESS_SHARING_LEVEL`;
ALTER TABLE imf_table_cleaned DROP COLUMN `ACCESS_SHARING_NOTES`;
ALTER TABLE imf_table_cleaned DROP COLUMN `AUTHOR`;
ALTER TABLE imf_table_cleaned DROP COLUMN `DECIMALS_DISPLAYED`;
ALTER TABLE imf_table_cleaned DROP COLUMN `DEPARTMENT`;
ALTER TABLE imf_table_cleaned DROP COLUMN `DERIVATION_TYPE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `DOI`;
ALTER TABLE imf_table_cleaned DROP COLUMN `FREQUENCY`;
ALTER TABLE imf_table_cleaned DROP COLUMN `FULL_DESCRIPTION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `FULL_SOURCE_CITATION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `INDICATOR`;
ALTER TABLE imf_table_cleaned DROP COLUMN `KEY_INDICATOR`;
ALTER TABLE imf_table_cleaned DROP COLUMN `KEYWORDS`;
ALTER TABLE imf_table_cleaned DROP COLUMN `KEYWORDS_DATASET`;
ALTER TABLE imf_table_cleaned DROP COLUMN `LANGUAGE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `LICENSE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `METHODOLOGY`;
ALTER TABLE imf_table_cleaned DROP COLUMN `METHODOLOGY_NOTES`;
ALTER TABLE imf_table_cleaned DROP COLUMN `OBS_MEASURE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `OVERLAP`;
ALTER TABLE imf_table_cleaned DROP COLUMN `PRECISION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `PUBLICATION_DATE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `PUBLISHER`;
ALTER TABLE imf_table_cleaned DROP COLUMN `rank_number`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SECTOR`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SECURITY_CLASSIFICATION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SEX`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SHORT_SOURCE_CITATION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SOURCE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `STATUS`;
ALTER TABLE imf_table_cleaned DROP COLUMN `SUGGESTED_CITATION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `TOPIC`;
ALTER TABLE imf_table_cleaned DROP COLUMN `TOPIC_DATASET`;
ALTER TABLE imf_table_cleaned DROP COLUMN `TRANSFORMATION`;
ALTER TABLE imf_table_cleaned DROP COLUMN `UNIT`;
ALTER TABLE imf_table_cleaned DROP COLUMN `UPDATE_DATE`;
ALTER TABLE imf_table_cleaned DROP COLUMN `ï»¿"DATASET"`;
ALTER TABLE imf_table_cleaned DROP COLUMN `ACCOUNTING_ENTRY`;
ALTER TABLE imf_table_cleaned DROP COLUMN `INSTR_ASSET`; 

-- 6. Delete all rows with no data from 2004 - 2024
DELETE FROM imf_table_cleaned
WHERE (`2004` IS NULL OR `2004` = '')
  AND (`2005` IS NULL OR `2005` = '')
  AND (`2006` IS NULL OR `2006` = '')
  AND (`2007` IS NULL OR `2007` = '')
  AND (`2008` IS NULL OR `2008` = '')
  AND (`2009` IS NULL OR `2009` = '')
  AND (`2010` IS NULL OR `2010` = '')
  AND (`2011` IS NULL OR `2011` = '')
  AND (`2012` IS NULL OR `2012` = '')
  AND (`2013` IS NULL OR `2013` = '')
  AND (`2014` IS NULL OR `2014` = '')
  AND (`2015` IS NULL OR `2015` = '')
  AND (`2016` IS NULL OR `2016` = '')
  AND (`2017` IS NULL OR `2017` = '')
  AND (`2018` IS NULL OR `2018` = '')
  AND (`2019` IS NULL OR `2019` = '')
  AND (`2020` IS NULL OR `2020` = '')
  AND (`2021` IS NULL OR `2021` = '')
  AND (`2022` IS NULL OR `2022` = '')
  AND (`2023` IS NULL OR `2023` = '')
  AND (`2024` IS NULL OR `2024` = '');

-- 7. Update imf_table_cleaned to replace blank values and other data
-- a. Fill Values in FA_INDICATORS, using the strings before the 1st comma in SERIES_NAME
UPDATE imf_table_cleaned
SET FA_INDICATORS = SUBSTRING_INDEX(SERIES_NAME, ',', 1)
WHERE FA_INDICATORS IS NULL OR FA_INDICATORS = '' 
;

-- b. Modify Country titles using Case Statements
UPDATE imf_table_cleaned
SET COUNTRY = CASE
	WHEN COUNTRY = 'CÃ´te d''Ivoire' THEN "Côte d'Ivoire"
	WHEN COUNTRY = 'Congo, Republic of' THEN 'Republic of Congo'
    WHEN COUNTRY = 'Congo, Democratic Republic of the' THEN 'Democratic Republic of Congo'
    WHEN COUNTRY LIKE '%,%' THEN SUBSTRING_INDEX(COUNTRY, ',', 1)
    ELSE COUNTRY
END;

-- c. Fill in COUNTERPART_SECTOR
SELECT SERIES_NAME,
    CASE 
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 6
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-6),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 5
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-5),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 4
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-4),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 3
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-3),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 2
        THEN 'National'
        
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 6
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -6), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 5
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -5), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 4
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -4), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 3 
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -3), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 2 
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -2), ',', 1))
        ELSE 'National'
    END AS extracted_value
FROM imf_table_cleaned
WHERE (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) >= 2;

-- cii. Fill in blanks in COUNTERPART_SECTOR by extracting the second element of each list under SERIES_NAME
UPDATE imf_table_cleaned
SET COUNTERPART_SECTOR = CASE 
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 6
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-6),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 5
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-5),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 4
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-4),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 3
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME,',',-3),',',1))
		WHEN SERIES_NAME LIKE '%Per_1%' > 0 AND (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 2
        THEN 'National'
        
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 6
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -6), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 5
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -5), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 4
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -4), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 3 
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -3), ',', 1))
        WHEN (LENGTH(SERIES_NAME) - LENGTH(REPLACE(SERIES_NAME, ',', ''))) = 2 
		THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SERIES_NAME, ',', -2), ',', 1))
        ELSE 'National'
    END
;

-- 7ciii. Adjust COUNTERPART_SECTOR to include '(SMEs)' where relevant using case statements.
UPDATE imf_table_cleaned
SET COUNTERPART_SECTOR = CASE 
	WHEN SERIES_CODE LIKE '%SMES%' THEN CONCAT(COUNTERPART_SECTOR,' (SMEs)')
    ELSE COUNTERPART_SECTOR
END;

-- 7d. Adjust FA_INDICATORS to include 'Male', 'Female' or '(SMEs)' where relevant using case statements.
UPDATE imf_table_cleaned
SET FA_INDICATORS = CASE 
	WHEN SERIES_CODE LIKE '%\_M.%' THEN CONCAT(FA_INDICATORS,' - Male')
    WHEN SERIES_CODE LIKE '%\_F.%' THEN CONCAT(FA_INDICATORS,' - Female')
    WHEN SERIES_CODE LIKE '%SMES%' THEN CONCAT(FA_INDICATORS,' (SMEs)')
    ELSE FA_INDICATORS
END;

-- 7e. DROP SERIES_NAME Column & Set empty strings in fields 2004-2024 to NULL
ALTER TABLE imf_table_cleaned DROP COLUMN SERIES_NAME;

SELECT CONCAT(
'UPDATE imf_table_cleaned SET `',`COLUMN_NAME`,'` = NULL WHERE `',`COLUMN_NAME`,'` = "";'
) AS columns_to_change
FROM INFORMATION_SCHEMA.COLUMNS
WHERE `TABLE_SCHEMA` = 'data_portfolio_projects'
AND `TABLE_NAME` = 'imf_table_cleaned'
AND `COLUMN_NAME` NOT IN (
'SERIES_CODE', 'COUNTRY', 'FA_INDICATORS', 'TYPE_OF_TRANSFORMATION','SCALE', 
'COUNTERPART_SECTOR'
)
;
UPDATE imf_table_cleaned SET `2004` = NULL WHERE `2004` = "";
UPDATE imf_table_cleaned SET `2005` = NULL WHERE `2005` = "";
UPDATE imf_table_cleaned SET `2006` = NULL WHERE `2006` = "";
UPDATE imf_table_cleaned SET `2007` = NULL WHERE `2007` = "";
UPDATE imf_table_cleaned SET `2008` = NULL WHERE `2008` = "";
UPDATE imf_table_cleaned SET `2009` = NULL WHERE `2009` = "";
UPDATE imf_table_cleaned SET `2010` = NULL WHERE `2010` = "";
UPDATE imf_table_cleaned SET `2011` = NULL WHERE `2011` = "";
UPDATE imf_table_cleaned SET `2012` = NULL WHERE `2012` = "";
UPDATE imf_table_cleaned SET `2013` = NULL WHERE `2013` = "";
UPDATE imf_table_cleaned SET `2014` = NULL WHERE `2014` = "";
UPDATE imf_table_cleaned SET `2015` = NULL WHERE `2015` = "";
UPDATE imf_table_cleaned SET `2016` = NULL WHERE `2016` = "";
UPDATE imf_table_cleaned SET `2017` = NULL WHERE `2017` = "";
UPDATE imf_table_cleaned SET `2018` = NULL WHERE `2018` = "";
UPDATE imf_table_cleaned SET `2019` = NULL WHERE `2019` = "";
UPDATE imf_table_cleaned SET `2020` = NULL WHERE `2020` = "";
UPDATE imf_table_cleaned SET `2021` = NULL WHERE `2021` = "";
UPDATE imf_table_cleaned SET `2022` = NULL WHERE `2022` = "";
UPDATE imf_table_cleaned SET `2023` = NULL WHERE `2023` = "";
UPDATE imf_table_cleaned SET `2024` = NULL WHERE `2024` = "";

-- 8. Split Data up by their data types and insert data for Southern African countries
-- 8a. Numerical data table for SADC
CREATE TABLE imf_sadc_numerical_data  -- table for integer values
LIKE imf_table_cleaned;

INSERT INTO imf_sadc_numerical_data
SELECT *
FROM imf_table_cleaned
WHERE COUNTRY IN (
    'Angola',
    'Botswana',
    'Comoros',
    'Eswatini',
    'Lesotho',
    'Madagascar',
    'Malawi',
    'Mauritius',
    'Mozambique',
    'Namibia',
    'Seychelles',
    'South Africa',
    'Zambia',
    'Zimbabwe'
)
AND TYPE_OF_TRANSFORMATION LIKE 'Number'
ORDER BY COUNTRY, FA_INDICATORS
;

-- Query to batch generate 'ALTER TABLE... MODIFY COLUMN...' statements from 2004-2024
SELECT CONCAT(
'ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `',
`COLUMN_NAME`,
'`', ' INT;'
) AS columns_to_change
FROM INFORMATION_SCHEMA.COLUMNS
WHERE `TABLE_SCHEMA` = 'data_portfolio_projects'
AND `TABLE_NAME` = 'imf_sadc_numerical_data'
AND `COLUMN_NAME` NOT IN (
'SERIES_CODE', 'COUNTRY', 'FA_INDICATORS', 'TYPE_OF_TRANSFORMATION','SCALE', 
'COUNTERPART_SECTOR', 'SERIES_NAME'
)
;

-- Converting values in imf_sadc_numerical_data to integer value
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2004` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2005` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2006` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2007` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2008` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2009` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2010` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2011` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2012` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2013` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2014` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2015` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2016` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2017` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2018` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2019` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2020` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2021` INT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2022` BIGINT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2023` BIGINT;
ALTER TABLE imf_sadc_numerical_data MODIFY COLUMN `2024` BIGINT;


-- 8b. Proportional data table for SADC
CREATE TABLE imf_sadc_proportional_data -- table for float values
LIKE imf_table_cleaned; 

INSERT INTO imf_sadc_proportional_data
SELECT *
FROM imf_table_cleaned
WHERE COUNTRY IN (
    'Angola',
    'Botswana',
    'Comoros',
    'Eswatini',
    'Lesotho',
    'Madagascar',
    'Malawi',
    'Mauritius',
    'Mozambique',
    'Namibia',
    'Seychelles',
    'South Africa',
    'Zambia',
    'Zimbabwe'
)
AND TYPE_OF_TRANSFORMATION NOT LIKE 'Number'
ORDER BY COUNTRY, FA_INDICATORS
;
-- Query to batch generate 'UPDATE imf_sadc_proportional_data... SET...' statements from 2004-2024
SELECT CONCAT(
'UPDATE imf_sadc_proportional_data SET `',
`COLUMN_NAME`,'`', ' = ROUND(`',`COLUMN_NAME`,'`,2);'
) AS columns_to_change
FROM INFORMATION_SCHEMA.COLUMNS
WHERE `TABLE_SCHEMA` = 'data_portfolio_projects'
AND `TABLE_NAME` = 'imf_sadc_proportional_data'
AND `COLUMN_NAME` NOT IN (
'SERIES_CODE', 'COUNTRY', 'FA_INDICATORS', 'TYPE_OF_TRANSFORMATION','SCALE', 
'COUNTERPART_SECTOR'
)
;

-- Converting values in imf_sadc_proportional_data to float with 2 decimal places
UPDATE imf_sadc_proportional_data SET `2004` = ROUND(`2004`,2);
UPDATE imf_sadc_proportional_data SET `2005` = ROUND(`2005`,2);
UPDATE imf_sadc_proportional_data SET `2006` = ROUND(`2006`,2);
UPDATE imf_sadc_proportional_data SET `2007` = ROUND(`2007`,2);
UPDATE imf_sadc_proportional_data SET `2008` = ROUND(`2008`,2);
UPDATE imf_sadc_proportional_data SET `2009` = ROUND(`2009`,2);
UPDATE imf_sadc_proportional_data SET `2010` = ROUND(`2010`,2);
UPDATE imf_sadc_proportional_data SET `2011` = ROUND(`2011`,2);
UPDATE imf_sadc_proportional_data SET `2012` = ROUND(`2012`,2);
UPDATE imf_sadc_proportional_data SET `2013` = ROUND(`2013`,2);
UPDATE imf_sadc_proportional_data SET `2014` = ROUND(`2014`,2);
UPDATE imf_sadc_proportional_data SET `2015` = ROUND(`2015`,2);
UPDATE imf_sadc_proportional_data SET `2016` = ROUND(`2016`,2);
UPDATE imf_sadc_proportional_data SET `2017` = ROUND(`2017`,2);
UPDATE imf_sadc_proportional_data SET `2018` = ROUND(`2018`,2);
UPDATE imf_sadc_proportional_data SET `2019` = ROUND(`2019`,2);
UPDATE imf_sadc_proportional_data SET `2020` = ROUND(`2020`,2);
UPDATE imf_sadc_proportional_data SET `2021` = ROUND(`2021`,2);
UPDATE imf_sadc_proportional_data SET `2022` = ROUND(`2022`,2);
UPDATE imf_sadc_proportional_data SET `2023` = ROUND(`2023`,2);
UPDATE imf_sadc_proportional_data SET `2024` = ROUND(`2024`,2);


-- Querying Final Tables
SELECT *
FROM imf_sadc_numerical_data
-- FROM imf_sadc_proportional_data
;

-- END