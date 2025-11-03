-- Exploratory Data Analysis of IMF Survey in Southern Africa

-- ==============================================================================================================
-- 1. ANALYSIS OF MOBILE VS TRADITIONAL BANKING
-- This query provides insight on the banking vs mobile money sector in Southern Africa, by exploring the following:
-- a) Which sector has a higher adoption rate in each country? Banking or Mobile Money?
-- b) Has financial access improved or worsened in each country in terms of access per 1,000 adults?
-- c) How much of the changes in bank deposits and mobile money accounts correlate with population growth?

-- 1(a) and (b) were calculated using CTEs, joins and Case statements to compare the difference between
-- (i) the Compound Annual Growth Rate of deposit accounts, and (ii) CAGR of mobile money accounts,
-- for each country over a 5-Year period (2020 - 2024).
-- 1(c) uses regression analysis, with reference data from the World Bank Population Indicator (2020-2024)
-- ==============================================================================================================

-- 1(a) Which sector has a higher adoption rate in each country?
-- 1(b) Has financial access improved or worsened in each country in terms of access per 1,000 adults?
WITH bank_deposit_accounts AS
(
SELECT p.COUNTRY, p.FA_INDICATORS,p.TYPE_OF_TRANSFORMATION,p.COUNTERPART_SECTOR,
p.`2020`, p.`2021`, p.`2022`, p.`2023`, COALESCE(p.`2024`,p.`2023`, p.`2022`) AS `2024`,
ROUND((POWER((COALESCE(p.`2024`,p.`2023`)/p.`2020`),1/5)-1)*100,2) AS `5Y CAGR of Deposit Accounts per 1,000 adults (%)`,

n.FA_INDICATORS AS FAI_n,
n.TYPE_OF_TRANSFORMATION AS TOT_n,
n.COUNTERPART_SECTOR AS CS_n,
n.`2020` AS `n.2020`, n.`2021` AS `n.2021`, n.`2022` AS `n.2022`, n.`2023` AS `n.2023`, COALESCE(n.`2024`,n.`2023`, n.`2022`) AS `n.2024`,
ROUND((POWER((COALESCE(n.`2024`,n.`2023`)/n.`2020`),1/5)-1)*100,2) AS `5Y CAGR of Deposit Accounts (%)`

FROM imf_sadc_proportional_data p
INNER JOIN imf_sadc_numerical_data n -- Joining the numerical data table with the proportional data table
	ON p.COUNTRY = n.COUNTRY
    
WHERE p.FA_INDICATORS LIKE '%deposit accounts%' AND n.FA_INDICATORS = 'deposit accounts' -- filtering by deposit accounts,
AND p.COUNTERPART_SECTOR = 'Commercial banks' AND n.COUNTERPART_SECTOR = 'Commercial banks' -- commercial banks,
AND p.TYPE_OF_TRANSFORMATION LIKE '%1,000 adults%' AND n.TYPE_OF_TRANSFORMATION = 'Number' -- 'per 1,000 adults', integers from numerical data table,
AND p.SERIES_CODE NOT LIKE '%\_S14.%' AND n.SERIES_CODE NOT LIKE '%\_S14.%' -- and records without a series code containing the string 'S14'
ORDER BY p.FA_INDICATORS
),
-- CTE 2: mobile_money_accounts
mobile_money_accounts AS
(
SELECT p.COUNTRY, p.FA_INDICATORS,p.TYPE_OF_TRANSFORMATION,p.COUNTERPART_SECTOR,
p.`2020`, p.`2021`, p.`2022`, p.`2023`, COALESCE(p.`2024`,p.`2023`, p.`2022`) AS `2024`,
ROUND((POWER((COALESCE(p.`2024`,p.`2023`)/p.`2020`),1/5)-1)*100,2) AS `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`,

n.FA_INDICATORS AS FAI_n,
n.TYPE_OF_TRANSFORMATION AS TOT_n,
n.COUNTERPART_SECTOR AS CS_n,
n.`2020` AS `n.2020`, n.`2021` AS `n.2021`, n.`2022` AS `n.2022`, n.`2023` AS `n.2023`, COALESCE(n.`2024`,n.`2023`, n.`2022`) AS `n.2024`,
ROUND((POWER((COALESCE(n.`2024`,n.`2023`)/n.`2020`),1/5)-1)*100,2) AS `5Y CAGR of Mobile Money Accounts (%)`

FROM imf_sadc_proportional_data p
INNER JOIN imf_sadc_numerical_data n -- Joining the numerical data table with the proportional data table
	ON p.COUNTRY = n.COUNTRY
    
WHERE p.FA_INDICATORS LIKE '%active%mobile%accounts%' AND n.FA_INDICATORS LIKE '%active%mobile%accounts%' -- filtering by mobile money accounts,
AND p.TYPE_OF_TRANSFORMATION = 'Per 1,000 adults' AND n.TYPE_OF_TRANSFORMATION = 'Number' -- 'per 1,000 adults', integers from numerical data table,
ORDER BY p.FA_INDICATORS
)
SELECT 
bd.COUNTRY, 
`5Y CAGR of Deposit Accounts (%)`, 
`5Y CAGR of Deposit Accounts per 1,000 adults (%)`,
`5Y CAGR of Mobile Money Accounts (%)`, 
`5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`,
ROUND((
(`5Y CAGR of Deposit Accounts (%)` - `5Y CAGR of Deposit Accounts per 1,000 adults (%)`) +
(`5Y CAGR of Mobile Money Accounts (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`)
)/2,2) AS `Average Financial Gap`,
CASE
    WHEN ABS(
      `5Y CAGR of Deposit Accounts per 1,000 adults (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`
    ) < 4.5 THEN 'No Significant Difference'
    WHEN `5Y CAGR of Deposit Accounts per 1,000 adults (%)` > `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)` THEN 'Traditional Banking'
    WHEN `5Y CAGR of Deposit Accounts per 1,000 adults (%)` < `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)` THEN 'Mobile Money'
    ELSE 'Equal'
  END AS `Dominant Sector`,
CASE
	WHEN ROUND((
(`5Y CAGR of Deposit Accounts (%)` - `5Y CAGR of Deposit Accounts per 1,000 adults (%)`) +
(`5Y CAGR of Mobile Money Accounts (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`)
)/2,2) < -3 THEN 'Stronger, More access per adult'

	WHEN ROUND((
(`5Y CAGR of Deposit Accounts (%)` - `5Y CAGR of Deposit Accounts per 1,000 adults (%)`) +
(`5Y CAGR of Mobile Money Accounts (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`)
)/2,2) BETWEEN -3 AND 0 THEN 'Slightly Stronger, More access per adult'

    WHEN ROUND((
(`5Y CAGR of Deposit Accounts (%)` - `5Y CAGR of Deposit Accounts per 1,000 adults (%)`) +
(`5Y CAGR of Mobile Money Accounts (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`)
)/2,2) BETWEEN 0 AND 3 THEN 'Balanced growth, Inclusion Stable'

	WHEN ROUND((
(`5Y CAGR of Deposit Accounts (%)` - `5Y CAGR of Deposit Accounts per 1,000 adults (%)`) +
(`5Y CAGR of Mobile Money Accounts (%)` - `5Y CAGR of Mobile Money Accounts per 1,000 adults (%)`)
)/2,2) BETWEEN 3 AND 6 THEN 'Slightly Weaker, Less access per adult'
    ELSE 'Weaker, Less access per adult'
END AS `Financial Access Effectiveness`
FROM bank_deposit_accounts bd
JOIN mobile_money_accounts mm
	ON bd.COUNTRY = mm.COUNTRY
ORDER BY `Average Financial Gap`;

-- 1(c) How much of the changes in bank deposits and mobile money accounts correlate with population growth?
WITH long_data AS (
  -- 2020
  SELECT n.COUNTRY,
         '2020' AS YEAR,
         n.`2020` AS Deposit_Accounts,
         m.`2020` AS Mobile_Money_Accounts,
         p.`2020 [YR2020]` AS Population
  FROM imf_sadc_numerical_data n
  JOIN wb_pop_indicators p
    ON n.COUNTRY = p.`Country Name`
  JOIN imf_sadc_numerical_data m
    ON n.COUNTRY = m.COUNTRY
  WHERE n.FA_INDICATORS = 'deposit accounts'
  AND m.FA_INDICATORS LIKE 'active%mobile%accounts%'
    AND n.COUNTERPART_SECTOR = 'Commercial banks'
    AND n.SERIES_CODE NOT LIKE '%_S14.%'
    AND n.`2020` IS NOT NULL
    AND m.`2020` IS NOT NULL
    AND p.`2020 [YR2020]` IS NOT NULL

  UNION ALL

  -- 2021
  SELECT n.COUNTRY,
         '2021' AS YEAR,
         n.`2021` AS Deposit_Accounts,
         m.`2021` AS Mobile_Money_Accounts,
         p.`2021 [YR2021]` AS Population
  FROM imf_sadc_numerical_data n
  JOIN wb_pop_indicators p
    ON n.COUNTRY = p.`Country Name`
  JOIN imf_sadc_numerical_data m
    ON n.COUNTRY = m.COUNTRY
  WHERE n.FA_INDICATORS = 'deposit accounts'
  AND m.FA_INDICATORS LIKE 'active%mobile%accounts%'
    AND n.COUNTERPART_SECTOR = 'Commercial banks'
    AND n.SERIES_CODE NOT LIKE '%_S14.%'
    AND n.`2021` IS NOT NULL
    AND m.`2021` IS NOT NULL
    AND p.`2021 [YR2021]` IS NOT NULL

  UNION ALL

  -- 2022
  SELECT n.COUNTRY,
         '2022' AS YEAR,
         n.`2022` AS Deposit_Accounts,
         m.`2022` AS Mobile_Money_Accounts,
         p.`2022 [YR2022]` AS Population
  FROM imf_sadc_numerical_data n
  JOIN wb_pop_indicators p
    ON n.COUNTRY = p.`Country Name`
  JOIN imf_sadc_numerical_data m
    ON n.COUNTRY = m.COUNTRY
  WHERE n.FA_INDICATORS = 'deposit accounts'
  AND m.FA_INDICATORS LIKE 'active%mobile%accounts%'
    AND n.COUNTERPART_SECTOR = 'Commercial banks'
    AND n.SERIES_CODE NOT LIKE '%_S14.%'
    AND n.`2022` IS NOT NULL
    AND m.`2022` IS NOT NULL
    AND p.`2022 [YR2022]` IS NOT NULL

  UNION ALL

  -- 2023
  SELECT n.COUNTRY,
         '2023' AS YEAR,
         n.`2023` AS Deposit_Accounts,
         m.`2023` AS Mobile_Money_Accounts,
         p.`2023 [YR2023]` AS Population
  FROM imf_sadc_numerical_data n
  JOIN wb_pop_indicators p
    ON n.COUNTRY = p.`Country Name`
  JOIN imf_sadc_numerical_data m
    ON n.COUNTRY = m.COUNTRY
  WHERE n.FA_INDICATORS = 'deposit accounts'
  AND m.FA_INDICATORS LIKE 'active%mobile%accounts%'
    AND n.COUNTERPART_SECTOR = 'Commercial banks'
    AND n.SERIES_CODE NOT LIKE '%_S14.%'
    AND n.`2023` IS NOT NULL
    AND m.`2023` IS NOT NULL
    AND p.`2023 [YR2023]` IS NOT NULL

  UNION ALL

  -- 2024
  SELECT n.COUNTRY,
         '2024' AS YEAR,
         n.`2024` AS Deposit_Accounts,
         m.`2024` AS Mobile_Money_Accounts,
         p.`2024 [YR2024]` AS Population
  FROM imf_sadc_numerical_data n
  JOIN wb_pop_indicators p
    ON n.COUNTRY = p.`Country Name`
  JOIN imf_sadc_numerical_data m
    ON n.COUNTRY = m.COUNTRY
  WHERE n.FA_INDICATORS = 'deposit accounts'
  AND m.FA_INDICATORS LIKE 'active%mobile%accounts%'
    AND n.COUNTERPART_SECTOR = 'Commercial banks'
    AND n.SERIES_CODE NOT LIKE '%_S14.%'
    AND n.`2024` IS NOT NULL
    AND m.`2024` IS NOT NULL
    AND p.`2024 [YR2024]` IS NOT NULL
),
-- Create variables for regression analysis in agg cte (n, sumX, sumY etc.)
agg AS (
  SELECT
    COUNTRY,
    COUNT(*) AS n,
    SUM(Population) AS sumX,
    SUM(Deposit_Accounts) AS sumY,
    SUM(Mobile_Money_Accounts) AS sumY_02,
    SUM(Population * Deposit_Accounts) AS sumXY,
    SUM(Population * Mobile_Money_Accounts) AS sumXY_02,
    SUM(POWER(Population, 2)) AS sumX2,
    SUM(POWER(Deposit_Accounts, 2)) AS sumY2,
    SUM(POWER(Mobile_Money_Accounts, 2)) AS sumY_02_2
  FROM long_data
  GROUP BY COUNTRY
  HAVING COUNT(*) >= 2
)
SELECT
  COUNTRY,
  n,
  -- slope_deposit = beta1:
--  ROUND((sumXY - (sumX * sumY) / n) / NULLIF((sumX2 - (sumX * sumX) / n), 0),5) AS slope_deposit,
-- slope_mobile = beta1:
--  ROUND((sumXY_02 - (sumX * sumY_02) / n) / NULLIF((sumX2 - (sumX * sumX) / n), 0),5) AS slope_mobile,
  
  -- intercept_deposit = beta0:
--  ROUND((sumY / n) - (((sumXY - (sumX * sumY) / n) / NULLIF((sumX2 - (sumX * sumX) / n), 0)) * (sumX / n)),2) AS intercept_deposit,
    -- intercept_mobile = beta0
--  ROUND((sumY_02 / n) - (((sumXY_02 - (sumX * sumY_02) / n) / NULLIF((sumX2 - (sumX * sumX) / n), 0)) * (sumX / n)),2) AS intercept_mobile,
  
  -- R_squared_deposit:
--  ROUND(POWER((sumXY - (sumX * sumY) / n), 2) / NULLIF(((sumX2 - (sumX * sumX) / n) * (sumY2 - (sumY * sumY) / n)),0),5) AS R_squared_deposit,
  -- R_squared_mobile:
--  ROUND(POWER((sumXY_02 - (sumX * sumY_02) / n), 2) / NULLIF(((sumX2 - (sumX * sumX) / n) * (sumY_02_2 - (sumY_02 * sumY_02) / n)),0),5) AS R_squared_mobile,
 
  -- R_squared_deposit as percent:
ROUND(100 * POWER((sumXY - (sumX * sumY) / n), 2) / NULLIF(((sumX2 - (sumX * sumX) / n) * (sumY2 - (sumY * sumY) / n)),0),2) AS deposit_correlation_perc,
  -- R_squared_mobile as percent:
ROUND(100 * POWER((sumXY_02 - (sumX * sumY_02) / n), 2) / NULLIF(((sumX2 - (sumX * sumX) / n) * (sumY_02_2 - (sumY_02 * sumY_02) / n)),0),2) AS mobile_correlation_perc,
  -- deposit_conclusion
    CONCAT(ROUND(100 * POWER((sumXY - (sumX * sumY) / n), 2) /
  NULLIF(
    ((sumX2 - (sumX * sumX) / n) * (sumY2 - (sumY * sumY) / n)),
    0
  ),2),'% correlation with population growth') AS deposit_acc_conclusion,
  -- mobile_conclusion
    CONCAT(ROUND(100 * POWER((sumXY_02 - (sumX * sumY_02) / n), 2) /
  NULLIF(
    ((sumX2 - (sumX * sumX) / n) * (sumY_02_2 - (sumY_02 * sumY_02) / n)),
    0
  ),2),'% correlation with population growth') AS mobile_money_acc_conclusion
  
FROM agg
ORDER BY COUNTRY
;

-- ================================================================================================
-- 2. GENDER PARITY ANALYSIS
-- Has financial inclusion for women improved faster or slower than men from 2020 - 2024?

-- This query calculates the gender parity for Southern African borrowers and depositors in 2024,
-- the average annual depositor and borrower improvement, and the years to depositor and borrower parity,
-- using CTEs, Unions & Case statements to unpivot data, and summarises the results using 
-- window functions & aggregate functions.
-- ================================================================================================

-- 2. Has financial inclusion for women improved faster or slower than men from 2020 - 2024?
WITH unpivoted_data AS (
    -- Unpivot the year columns into rows
    SELECT 
        country,
        fa_indicators,
        counterpart_sector,
        type_of_transformation,
        2020 as year,
        `2020` as value
    FROM imf_sadc_numerical_data
    WHERE counterpart_sector = 'Commercial banks'
      AND fa_indicators IN ('Depositors - Female', 'Depositors - Male', 
                            'Borrowers - Female', 'Borrowers - Male')
    
    UNION ALL
    SELECT country, fa_indicators, counterpart_sector, type_of_transformation, 2021, `2021` FROM imf_sadc_numerical_data
    WHERE counterpart_sector = 'Commercial banks' AND fa_indicators IN ('Depositors - Female', 'Depositors - Male', 'Borrowers - Female', 'Borrowers - Male')
    
    UNION ALL
    SELECT country, fa_indicators, counterpart_sector, type_of_transformation, 2022, `2022` FROM imf_sadc_numerical_data
    WHERE counterpart_sector = 'Commercial banks' AND fa_indicators IN ('Depositors - Female', 'Depositors - Male', 'Borrowers - Female', 'Borrowers - Male')
    
    UNION ALL
    SELECT country, fa_indicators, counterpart_sector, type_of_transformation, 2023, `2023` FROM imf_sadc_numerical_data
    WHERE counterpart_sector = 'Commercial banks' AND fa_indicators IN ('Depositors - Female', 'Depositors - Male', 'Borrowers - Female', 'Borrowers - Male')
    
    UNION ALL
    SELECT country, fa_indicators, counterpart_sector, type_of_transformation, 2024, `2024` FROM imf_sadc_numerical_data
    WHERE counterpart_sector = 'Commercial banks' AND fa_indicators IN ('Depositors - Female', 'Depositors - Male', 'Borrowers - Female', 'Borrowers - Male')
),

-- Pivot female and male values for each indicator
gender_comparison AS (
    SELECT 
        country,
        year,
        MAX(CASE WHEN fa_indicators = 'Depositors - Female' THEN value END) as depositors_female,
        MAX(CASE WHEN fa_indicators = 'Depositors - Male' THEN value END) as depositors_male,
        MAX(CASE WHEN fa_indicators = 'Borrowers - Female' THEN value END) as borrowers_female,
        MAX(CASE WHEN fa_indicators = 'Borrowers - Male' THEN value END) as borrowers_male
    FROM unpivoted_data
    GROUP BY country, year
),

-- Calculate parity ratio (female as % of male, where 100% = parity)
parity_ratios AS (
    SELECT 
        country,
        year,
        depositors_female,
        depositors_male,
        borrowers_female,
        borrowers_male,
        -- Calculate female as percentage of male for each indicator
        CASE 
            WHEN depositors_male > 0 AND depositors_female > 0
            THEN ROUND((depositors_female / depositors_male) * 100, 2)
            ELSE NULL 
        END as depositor_parity_pct,
        CASE 
            WHEN borrowers_male > 0 AND borrowers_female > 0
            THEN ROUND((borrowers_female/ borrowers_male) * 100, 2)
            ELSE NULL 
        END as borrower_parity_pct,
        -- Calculate absolute gaps
        (depositors_male - depositors_female) as depositor_gap,
        (borrowers_male - borrowers_female) as borrower_gap
    FROM gender_comparison
),

-- Calculate trend: parity change per year
trend_calculation AS (
    SELECT 
        country,
        year,
        depositor_parity_pct,
        borrower_parity_pct,
        -- Get previous year's values for trend calculation
        LAG(depositor_parity_pct) OVER (PARTITION BY country ORDER BY year) as prev_depositor_parity,
        LAG(borrower_parity_pct) OVER (PARTITION BY country ORDER BY year) as prev_borrower_parity
    FROM parity_ratios
),

-- Calculate annual improvement rate
improvement_rate AS (
    SELECT 
        country,
        year,
        depositor_parity_pct,
        borrower_parity_pct,
        (depositor_parity_pct - prev_depositor_parity) as annual_depositor_improvement,
        (borrower_parity_pct - prev_borrower_parity) as annual_borrower_improvement
    FROM trend_calculation
    WHERE prev_depositor_parity IS NOT NULL
),

-- Get 2024 parity and average improvement rate (2021-2024)
current_and_trend AS (
    SELECT 
        country,
        MAX(CASE WHEN year = 2024 THEN depositor_parity_pct END) as depositor_parity_2024,
        MAX(CASE WHEN year = 2024 THEN borrower_parity_pct END) as borrower_parity_2024,
        -- Average annual improvement over the period (excluding 2020, since we need prior year)
        ROUND(AVG(annual_depositor_improvement),2) as avg_annual_depositor_improvement,
        ROUND(AVG(annual_borrower_improvement),2) as avg_annual_borrower_improvement
    FROM improvement_rate
    GROUP BY country
)

-- Calculate years to parity
SELECT *,
    
    -- FORMULA: Years to Parity = (100 - Current Parity %) / Annual Improvement Rate
    -- Only calculates improving (positive rate) and not already at parity
    CASE 
        WHEN depositor_parity_2024 < 100 AND avg_annual_depositor_improvement > 0 
        THEN ROUND((100 - depositor_parity_2024) / avg_annual_depositor_improvement, 1)
        WHEN depositor_parity_2024 >= 100 
        THEN 0 -- Already at parity
        WHEN avg_annual_depositor_improvement <= 0 
        THEN NULL -- Not improving or declining
        ELSE NULL
    END as years_to_depositor_parity,
    
    CASE 
        WHEN borrower_parity_2024 < 100 AND avg_annual_borrower_improvement > 0 
        THEN ROUND((100 - borrower_parity_2024) / avg_annual_borrower_improvement, 1)
        WHEN borrower_parity_2024 >= 100 
        THEN 0
        WHEN avg_annual_borrower_improvement <= 0 
        THEN NULL
        ELSE NULL
    END as years_to_borrower_parity,
    
    -- Classification for visualization
    CASE 
        WHEN avg_annual_depositor_improvement > 2 THEN 'Fast Improvement'
        WHEN avg_annual_depositor_improvement BETWEEN 0.5 AND 2 THEN 'Moderate Improvement'
        WHEN avg_annual_depositor_improvement > 0 AND avg_annual_depositor_improvement < 0.5 THEN 'Slow Improvement'
        WHEN avg_annual_depositor_improvement <= 0 THEN 'Stagnant/Declining'
        ELSE 'Unknown'
    END as depositor_trend_class,
    
    CASE 
        WHEN avg_annual_borrower_improvement > 2 THEN 'Fast Improvement'
        WHEN avg_annual_borrower_improvement BETWEEN 0.5 AND 2 THEN 'Moderate Improvement'
        WHEN avg_annual_borrower_improvement > 0 AND avg_annual_borrower_improvement < 0.5 THEN 'Slow Improvement'
        WHEN avg_annual_borrower_improvement <= 0 THEN 'Stagnant/Declining'
        ELSE 'Unknown'
    END as borrower_trend_class
    
FROM current_and_trend
ORDER BY years_to_depositor_parity ASC; --  NULLS LAST

-- ================================================================================================
-- 3. INFRASTRUCTURE EFFICIENCY 
-- This section analyses the infrastructure efficiency of banks, to answer the following questions:
-- a) Are banks in Southern Africa building branches or pivoting to digital channels?
-- b) Which markets achieve higher financial inclusion with fewer physical touchpoints?

-- The following query was prepared by unpivoting multiple rows into columns & appending queries for 
-- 2020-2024, using WHERE & Unions. Then, metrics for the count of agents, atms and branches were 
-- referenced together with WB Population data to get the total infrastructure per 100,000 adults,
-- in order to calculate the depositor efficiency ratio of each country, using CTEs, Joins and Case Statements.
-- ================================================================================================

WITH appended_atm_agent_data AS (
-- 2020
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2020 as year, `2020` as value
FROM imf_sadc_numerical_data 
WHERE FA_INDICATORS LIKE '%agent%' OR FA_INDICATORS LIKE '%ATM%'
OR (FA_INDICATORS LIKE '%branches%' AND COUNTERPART_SECTOR = 'Commercial banks')
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2020 as year, `2020` as value
FROM imf_sadc_proportional_data
WHERE (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km')
OR (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults')
OR (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks' AND SERIES_CODE NOT LIKE '%_S14.%')

-- 2021
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2021 as year, `2021` as value
FROM imf_sadc_numerical_data 
WHERE FA_INDICATORS LIKE '%agent%' OR FA_INDICATORS LIKE '%ATM%'
OR (FA_INDICATORS LIKE '%branches%' AND COUNTERPART_SECTOR = 'Commercial banks')
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2021 as year, `2021` as value
FROM imf_sadc_proportional_data
WHERE (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km')
OR (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults')
OR (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks' AND SERIES_CODE NOT LIKE '%_S14.%')

-- 2022
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2022 as year, `2022` as value
FROM imf_sadc_numerical_data 
WHERE FA_INDICATORS LIKE '%agent%' OR FA_INDICATORS LIKE '%ATM%'
OR (FA_INDICATORS LIKE '%branches%' AND COUNTERPART_SECTOR = 'Commercial banks')
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2022 as year, `2022` as value
FROM imf_sadc_proportional_data
WHERE (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km')
OR (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults')
OR (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks' AND SERIES_CODE NOT LIKE '%_S14.%')

-- 2023
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2023 as year, `2023` as value
FROM imf_sadc_numerical_data 
WHERE FA_INDICATORS LIKE '%agent%' OR FA_INDICATORS LIKE '%ATM%'
OR (FA_INDICATORS LIKE '%branches%' AND COUNTERPART_SECTOR = 'Commercial banks')
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2023 as year, `2023` as value
FROM imf_sadc_proportional_data
WHERE (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km')
OR (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults')
OR (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks' AND SERIES_CODE NOT LIKE '%_S14.%')

-- 2024
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2024 as year, `2024` as value
FROM imf_sadc_numerical_data 
WHERE FA_INDICATORS LIKE '%agent%' OR FA_INDICATORS LIKE '%ATM%'
OR (FA_INDICATORS LIKE '%branches%' AND COUNTERPART_SECTOR = 'Commercial banks')
UNION ALL
SELECT COUNTRY, FA_INDICATORS, TYPE_OF_TRANSFORMATION, COUNTERPART_SECTOR, 2024 as year, `2024` as value
FROM imf_sadc_proportional_data
WHERE (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km')
OR (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults')
OR (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks' AND SERIES_CODE NOT LIKE '%_S14.%')
),
-- World Bank Population table
population_table AS(
SELECT `Country Name`, 2020 as YEAR, `2020 [YR2020]` as value FROM wb_pop_indicators
UNION ALL
SELECT `Country Name`, 2021 as YEAR, `2021 [YR2021]` as value FROM wb_pop_indicators
UNION ALL
SELECT `Country Name`, 2022 as YEAR, `2022 [YR2022]` as value FROM wb_pop_indicators
UNION ALL
SELECT `Country Name`, 2023 as YEAR, `2023 [YR2023]` as value FROM wb_pop_indicators
UNION ALL
SELECT `Country Name`, 2024 as YEAR, `2024 [YR2024]` as value FROM wb_pop_indicators
ORDER BY `Country Name`, YEAR
),
-- Pivoting FA_INDICATOR rows into columns 
infrastructure_analysis AS(
SELECT COUNTRY, a.YEAR,
b.value AS adult_population,
MAX(CASE WHEN FA_INDICATORS = 'Automated teller machines (atms) country wide' THEN a.value END) as count_of_atms,
MAX(CASE WHEN FA_INDICATORS = 'Non branch retail agent outlets excluding headquarters' THEN a.value END) as count_of_agents,
MAX(CASE WHEN FA_INDICATORS = 'Branches excluding headquarters' THEN a.value END) as count_of_branches,
MAX(CASE WHEN (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 1,000 square km') THEN a.value END) as branches_per_1000_sqkm,
MAX(CASE WHEN (FA_INDICATORS = 'Number of commercial bank branches' AND TYPE_OF_TRANSFORMATION = 'Per 100,000 adults') THEN a.value END) as branches_per_100k_adults,
MAX(CASE WHEN (FA_INDICATORS = 'Number of depositors' AND COUNTERPART_SECTOR = 'Commercial banks') THEN a.value*100 END) as depositors_per_100k_adults

FROM appended_atm_agent_data a JOIN population_table b ON COUNTRY = `Country Name` AND a.YEAR = b.YEAR
GROUP BY COUNTRY, a.YEAR, adult_population
ORDER BY COUNTRY, a.year)

SELECT *,
(((count_of_atms + count_of_agents + count_of_branches)/ adult_population) * 100000) as total_infrastructure_per_100k,
(depositors_per_100k_adults/(((count_of_atms + count_of_agents + count_of_branches)/ adult_population) * 100000)) AS efficiency_ratio
FROM infrastructure_analysis
ORDER BY COUNTRY ASC, YEAR ASC, efficiency_ratio DESC
;
--

-- ================================================================================================
-- 4. SME CREDIT EVOLUTION:
-- This query examines the trend of bank loans to SMEs by asking the following:
-- Are banks increasing or decreasing SME lending relative to deposits?

-- This was prepared by appending data for different years altogether,
-- to calculate the Outstanding Loan-to-Deposit Ratio, LDR Account ratio, 
-- and the Borrowers-to-Depositors Ratio. This was done using CTEs, Unions, Group By and Case Statements.
-- ================================================================================================
WITH appended_sme_data AS (
-- 2020:
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2020 as YEAR, `2020` as value FROM imf_sadc_numerical_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%'
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2020 as YEAR, `2020` as value FROM imf_sadc_proportional_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%' AND TYPE_OF_TRANSFORMATION = 'Domestic currency'

-- 2021:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2021 as YEAR, `2021` as value FROM imf_sadc_numerical_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%'
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2021 as YEAR, `2021` as value FROM imf_sadc_proportional_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%' AND TYPE_OF_TRANSFORMATION = 'Domestic currency'

-- 2022:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2022 as YEAR, `2022` as value FROM imf_sadc_numerical_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%'
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2022 as YEAR, `2022` as value FROM imf_sadc_proportional_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%' AND TYPE_OF_TRANSFORMATION = 'Domestic currency'

-- 2023:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2023 as YEAR, `2023` as value FROM imf_sadc_numerical_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%'
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2023 as YEAR, `2023` as value FROM imf_sadc_proportional_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%' AND TYPE_OF_TRANSFORMATION = 'Domestic currency'

-- 2024:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2024 as YEAR, `2024` as value FROM imf_sadc_numerical_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%'
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2024 as YEAR, `2024` as value FROM imf_sadc_proportional_data
WHERE COUNTERPART_SECTOR LIKE '%banks%smes%' AND TYPE_OF_TRANSFORMATION = 'Domestic currency'
),
sme_credit_table AS(
SELECT COUNTRY, YEAR,
MAX(CASE WHEN FA_INDICATORS = 'Borrowers (SMEs)' THEN value END) as borrowers_smes,
MAX(CASE WHEN FA_INDICATORS = 'Loan accounts (SMEs)' THEN value END) as loan_accounts_smes,
MAX(CASE WHEN FA_INDICATORS = 'Outstanding deposits (SMEs)' THEN value END) as sme_outstanding_deposits_currency,
MAX(CASE WHEN FA_INDICATORS = 'Outstanding loans (SMEs)' THEN value END) as sme_outstanding_loans_currency,
MAX(CASE WHEN (FA_INDICATORS = 'Depositors (SMEs)') THEN value END) as depositors_smes,
MAX(CASE WHEN (FA_INDICATORS = 'Deposit accounts (SMEs)') THEN value END) as deposit_accounts_smes

FROM appended_sme_data
GROUP BY COUNTRY, YEAR
)

SELECT *,
ROUND((sme_outstanding_loans_currency/sme_outstanding_deposits_currency),2) AS outstanding_loan_to_deposit_ratio,
ROUND((loan_accounts_smes/deposit_accounts_smes),2) AS loan_to_deposit_acct_ratio,
ROUND((borrowers_smes/depositors_smes),2) AS borrowers_to_depositors_ratio

FROM sme_credit_table
ORDER BY COUNTRY, YEAR
;

-- ================================================================================================
-- 5. MOBILE MATURATION CURVE: 
-- Are registered accounts becoming active users over time?
-- Which countries have the biggest share of active mobile money accounts?
-- Which countries are improving their mobile money retention rate?

-- The query appends the relevant data from 2020-2024 to get the percentage of registered accounts 
-- with an active status, its proportion of the SADC total, and the percentage of mobile transactions 
-- at the regional level, using CTEs, Window Functions, Unions, Group By and Case Statements.
-- ================================================================================================

WITH appended_mobile_data AS (
-- 2020:
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2020 as YEAR, `2020` as value FROM imf_sadc_numerical_data
WHERE FA_INDICATORS = 'Active mobile money accounts' OR FA_INDICATORS = 'Registered mobile money accounts'
OR FA_INDICATORS LIKE '%average%transactions%' OR FA_INDICATORS LIKE 'mobile money transactions%'

-- 2021:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2021 as YEAR, `2021` as value FROM imf_sadc_numerical_data
WHERE FA_INDICATORS = 'Active mobile money accounts' OR FA_INDICATORS = 'Registered mobile money accounts'
OR FA_INDICATORS LIKE '%average%transactions%' OR FA_INDICATORS LIKE 'mobile money transactions%'

-- 2022:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2022 as YEAR, `2022` as value FROM imf_sadc_numerical_data
WHERE FA_INDICATORS = 'Active mobile money accounts' OR FA_INDICATORS = 'Registered mobile money accounts'
OR FA_INDICATORS LIKE '%average%transactions%' OR FA_INDICATORS LIKE 'mobile money transactions%'

-- 2023:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2023 as YEAR, `2023` as value FROM imf_sadc_numerical_data
WHERE FA_INDICATORS = 'Active mobile money accounts' OR FA_INDICATORS = 'Registered mobile money accounts'
OR FA_INDICATORS LIKE '%average%transactions%' OR FA_INDICATORS LIKE 'mobile money transactions%'

-- 2024:
UNION ALL
SELECT COUNTRY, FA_INDICATORS, COUNTERPART_SECTOR, 2024 as YEAR, `2024` as value FROM imf_sadc_numerical_data
WHERE FA_INDICATORS = 'Active mobile money accounts' OR FA_INDICATORS = 'Registered mobile money accounts'
OR FA_INDICATORS LIKE '%average%transactions%' OR FA_INDICATORS LIKE 'mobile money transactions%'
),

mobile_money_table AS(
SELECT COUNTRY, YEAR,
MAX(CASE WHEN FA_INDICATORS = 'Registered mobile money accounts' THEN value END) as registered_mm_accounts,
MAX(CASE WHEN FA_INDICATORS = 'Active mobile money accounts' THEN value END) as active_mm_accounts,
MAX(CASE WHEN FA_INDICATORS LIKE 'mobile money transactions%' THEN value END) as mm_transactions,
MAX(CASE WHEN FA_INDICATORS LIKE '%average%transactions%' THEN value END) as avg_txn_per_account

FROM appended_mobile_data
GROUP BY COUNTRY, YEAR
)

SELECT *,
ROUND((active_mm_accounts/registered_mm_accounts)*100,1) AS pct_of_active_accounts,
ROUND((active_mm_accounts/SUM(active_mm_accounts) OVER (PARTITION BY YEAR))*100,1) AS pct_of_active_accounts_sadc,
ROUND((mm_transactions/SUM(mm_transactions) OVER (PARTITION BY YEAR))*100,3) AS pct_of_mm_transactions_sadc
FROM mobile_money_table
ORDER BY COUNTRY, YEAR;