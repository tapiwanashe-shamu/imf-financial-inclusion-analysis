-- =====================================================
-- DATA QUALITY CHECKS FOR imf_staging_table
-- =====================================================

-- ️0. PRE-CALCULATE STATS
DROP TEMPORARY TABLE IF EXISTS imf_stats;
CREATE TEMPORARY TABLE imf_stats AS
SELECT
    COUNT(*) AS total_records,
    AVG(CAST(NULLIF(`2024`, '') AS DECIMAL(15,4))) AS avg_latest,
    STDDEV(CAST(NULLIF(`2024`, '') AS DECIMAL(15,4))) AS std_latest
FROM imf_staging_table
WHERE `2024` REGEXP '^-?[0-9]+(\\.[0-9]+)?$';

-- 9️⃣ OPTIONAL: VIEW PRE-CALCULATED STATS
SELECT * FROM imf_stats;

-- 1. COMPLETENESS CHECK
DROP TEMPORARY TABLE IF EXISTS completeness_check;
CREATE TEMPORARY TABLE completeness_check AS
SELECT 'COMPLETENESS' AS category,
       'Total number of fields (columns)' AS description,
       COUNT(*) AS value
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'data_portfolio_projects'
  AND TABLE_NAME = 'imf_staging_table'

UNION ALL

SELECT 'COMPLETENESS', 'Total number of records (rows)', COUNT(*)
FROM imf_staging_table
WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')

UNION ALL

SELECT 'COMPLETENESS', 'Number of records with ≥3 blank/null year fields', COUNT(*)
FROM (
  SELECT
    (CASE WHEN `2004` IS NULL OR `2004` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2005` IS NULL OR `2005` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2006` IS NULL OR `2006` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2007` IS NULL OR `2007` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2008` IS NULL OR `2008` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2009` IS NULL OR `2009` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2010` IS NULL OR `2010` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2011` IS NULL OR `2011` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2012` IS NULL OR `2012` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2013` IS NULL OR `2013` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2014` IS NULL OR `2014` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2015` IS NULL OR `2015` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2016` IS NULL OR `2016` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2017` IS NULL OR `2017` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2018` IS NULL OR `2018` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2019` IS NULL OR `2019` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2020` IS NULL OR `2020` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2021` IS NULL OR `2021` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2022` IS NULL OR `2022` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2023` IS NULL OR `2023` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2024` IS NULL OR `2024` = '' THEN 1 ELSE 0 END) AS blanks
  FROM imf_staging_table
  WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                    'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                    'South Africa','Zambia','Zimbabwe')
) AS t
WHERE blanks >= 3

UNION ALL

SELECT 'COMPLETENESS', 'Average number of blank/null year fields per record', ROUND(AVG(blanks),2)
FROM (
  SELECT
    (CASE WHEN `2004` IS NULL OR `2004` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2005` IS NULL OR `2005` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2006` IS NULL OR `2006` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2007` IS NULL OR `2007` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2008` IS NULL OR `2008` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2009` IS NULL OR `2009` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2010` IS NULL OR `2010` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2011` IS NULL OR `2011` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2012` IS NULL OR `2012` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2013` IS NULL OR `2013` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2014` IS NULL OR `2014` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2015` IS NULL OR `2015` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2016` IS NULL OR `2016` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2017` IS NULL OR `2017` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2018` IS NULL OR `2018` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2019` IS NULL OR `2019` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2020` IS NULL OR `2020` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2021` IS NULL OR `2021` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2022` IS NULL OR `2022` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2023` IS NULL OR `2023` = '' THEN 1 ELSE 0 END) +
    (CASE WHEN `2024` IS NULL OR `2024` = '' THEN 1 ELSE 0 END) AS blanks
  FROM imf_staging_table
  WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                    'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                    'South Africa','Zambia','Zimbabwe')
) AS t2

UNION ALL

SELECT 'COMPLETENESS', '% of records with all year fields blank/null',
       ROUND(
         SUM(
           CASE WHEN
             (`2004` IS NULL OR `2004` = '') AND (`2005` IS NULL OR `2005` = '') AND
             (`2006` IS NULL OR `2006` = '') AND (`2007` IS NULL OR `2007` = '') AND
             (`2008` IS NULL OR `2008` = '') AND (`2009` IS NULL OR `2009` = '') AND
             (`2010` IS NULL OR `2010` = '') AND (`2011` IS NULL OR `2011` = '') AND
             (`2012` IS NULL OR `2012` = '') AND (`2013` IS NULL OR `2013` = '') AND
             (`2014` IS NULL OR `2014` = '') AND (`2015` IS NULL OR `2015` = '') AND
             (`2016` IS NULL OR `2016` = '') AND (`2017` IS NULL OR `2017` = '') AND
             (`2018` IS NULL OR `2018` = '') AND (`2019` IS NULL OR `2019` = '') AND
             (`2020` IS NULL OR `2020` = '') AND (`2021` IS NULL OR `2021` = '') AND
             (`2022` IS NULL OR `2022` = '') AND (`2023` IS NULL OR `2023` = '') AND
             (`2024` IS NULL OR `2024` = '')
           THEN 1 ELSE 0 END
         ) / COUNT(*) * 100
       ,2)
FROM imf_staging_table
WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
;

-- 2. ACCURACY CHECK
DROP TEMPORARY TABLE IF EXISTS accuracy_check;
CREATE TEMPORARY TABLE accuracy_check AS
-- Rows with non-numeric entries in 2004–2024
SELECT 'ACCURACY' AS category, 'Rows with non-numeric entries in 2004–2024' AS description, COUNT(*) AS value
FROM imf_staging_table
WHERE CONCAT_WS(',', `2004`,`2005`,`2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,
                 `2013`,`2014`,`2015`,`2016`,`2017`,`2018`,`2019`,`2020`,`2021`,
                 `2022`,`2023`,`2024`)
      REGEXP '[^0-9,\\.-]'
AND COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')

-- Rows with non-numeric entries in 2004–2024 (%)                  
UNION ALL
SELECT 'ACCURACY' AS category, 'Rows with non-numeric entries in 2004–2024 (% of SADC records)',
       ROUND(COUNT(*) / (
       SELECT COUNT(*) FROM imf_staging_table
       WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
                  ) * 100, 2)
FROM imf_staging_table
WHERE CONCAT_WS(',', `2004`,`2005`,`2006`,`2007`,`2008`,`2009`,`2010`,`2011`,`2012`,
                 `2013`,`2014`,`2015`,`2016`,`2017`,`2018`,`2019`,`2020`,`2021`,
                 `2022`,`2023`,`2024`)
      REGEXP '[^0-9,\\.-]'
AND COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')

-- Rows with wrong data types
UNION ALL
SELECT 
  'ACCURACY',
  'Rows with wrong data types',
  COUNT(*)
FROM imf_staging_table
WHERE TYPE_OF_TRANSFORMATION = 'Number'
  AND (`2024` NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$' OR `2024` IS NULL OR `2024` = '')
  AND COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
 
-- Rows with wrong data types (%)
UNION ALL
SELECT 
  'ACCURACY',
  'Rows with wrong data types (% of SADC records)',
       ROUND(COUNT(*) / (
       SELECT COUNT(*) FROM imf_staging_table
       WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
                  ) * 100, 2)
FROM imf_staging_table
WHERE TYPE_OF_TRANSFORMATION = 'Number'
  AND (`2024` NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$' OR `2024` IS NULL OR `2024` = '')
  AND COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
;

-- 3. UNIQUENESS CHECK
DROP TEMPORARY TABLE IF EXISTS uniqueness_check;
CREATE TEMPORARY TABLE uniqueness_check AS
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY SERIES_CODE
) as rank_number
FROM imf_staging_table
), duplicate_table AS
(
SELECT *
FROM duplicate_cte
WHERE rank_number > 1
)
SELECT 'UNIQUENESS' AS category, 'Number of duplicate records' AS description, COUNT(*) AS value
FROM duplicate_table
WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
                  
UNION ALL
SELECT 'UNIQUENESS', 'Number of duplicate records (%)', 
ROUND((COUNT(*)/ 
(SELECT COUNT(*) FROM imf_staging_table
       WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
                  )) * 100, 2)
FROM duplicate_table
WHERE COUNTRY IN ('Angola','Botswana','Comoros','Eswatini','Lesotho','Madagascar',
                  'Malawi','Mauritius','Mozambique','Namibia','Seychelles',
                  'South Africa','Zambia','Zimbabwe')
;


-- 7️⃣ COMBINE ALL FINDINGS INTO ONE SUMMARY TABLE
DROP TEMPORARY TABLE IF EXISTS imf_data_quality_summary;
CREATE TEMPORARY TABLE imf_data_quality_summary AS
SELECT * FROM completeness_check
UNION ALL
SELECT * FROM accuracy_check
UNION ALL
SELECT * FROM uniqueness_check
;

-- 8️⃣ VIEW SUMMARY RESULTS
SELECT * FROM imf_data_quality_summary;
-- ------------------------------------------------------------