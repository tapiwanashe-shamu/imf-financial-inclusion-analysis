# IMF Financial Inclusion Analysis
![IMF Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/IMF-Seal_ENG_RGB.svg/500px-IMF-Seal_ENG_RGB.svg.png)
## EXECUTIVE SUMMARY

The **International Monetary Fund (IMF) Financial Access Survey (FAS)** is a global dataset that tracks **access and usage of financial services**. Since its launch in 2009, it has collected supply-side data from financial service providers, producing key indicators that guide policy decisions, business strategies, and international benchmarking for financial inclusion.  

This project relies on SQL analysis to explore **financial access trends in Southern Africa from 2020–2024**, analyzing how it evolved across **14 countries** on a dataset containing 195k records. This was prepared independently for 2 weeks to clean and analyse data in SQL, with dashboards built using Power BI to visualise trends related to the selected regions and periods.
The objective is to **identify key shifts, disparities, and opportunities - as well as provide actionable recommendations** for financial executives, policymakers, and development stakeholders, focusing on investment strategies in Southern Africa.  

### Data Structure
The analysis focuses on **five key areas**:

| Focus Area | Questions | Metrics |
|-------------|--------------|--------------|
| **1. Market Expansion** | Which sectors are most dominant? Traditional Banking or Mobile Money? | Comparison of traditional banking vs. mobile money using 5-year CAGR and correlation with population growth |
| **2. Gender Parity** | Has financial inclusion improved or worsened for female Depositors & Borrowers? | Trends in Gender Parity Index (GP) for depositors and borrowers, annual improvement, and projected time to parity |
| **3. Banking Infrastructure Efficiency** | Which markets achieved higher financial inclusion with fewer touchpoints? | Depositors per infrastructure point, depositors per 100,000 adults, total infrastructure per 100,000 adults (ATMs, branches, agents) |
| **4. SME Credit Trends** | What's the rate at which SME Lending has improved in the region? | Measured via the Loan-to-Deposit Ratio (LDR) |
| **5. Mobile User Maturation** | Are registered users becoming more active over time? | Share of active vs. registered accounts and each country’s share of SADC mobile transaction volume |

**Countries assessed:**  
*Angola, Botswana, Comoros, Eswatini, Lesotho, Madagascar, Malawi, Mauritius, Mozambique, Namibia, Seychelles, South Africa, Zambia, Zimbabwe.*  
**Time frame:** *2020–2024*

### Overview of Findings

The findings reveal a **regional shift towards mobile money channels**, **stagnant gender parity**, and **strained banking infrastructure** in several markets.  
While mobile adoption surged during that period, **active user engagement declined post-COVID-19**, suggesting potential market fatigue or policy misalignment.

### 1. Market Expansion: Traditional Banking vs. Mobile Money
- Except for **Madagascar** and **Eswatini**, the CAGR of deposit accounts was below or only marginally above mobile money account growth — signaling traditional banks’ loss of market share to digital platforms.  
- **Zimbabwe**, **Seychelles**, and **South Africa** showed weak correlations between deposit account growth and population growth, implying that **macroeconomic or policy factors**, rather than demographics, drove expansion.

### 2. Gender Parity
- Gender Parity progress remained **limited**. Between 2020–2024, average annual change was **-2% for depositors** and **+1% for borrowers**.  
- As of 2024, **women represent ~75% as many depositors and borrowers as men**, underscoring persistent barriers to equitable financial access.

### 3. Banking Infrastructure Efficiency
- **Mauritius, Zimbabwe, and Namibia** have the most saturated banking markets, each exceeding **2,000 depositors per banking touchpoint**.  
- **Mauritius** stands out — every adult holds at least **two deposit accounts**, but infrastructure growth lags behind.  
- **Botswana** and **Madagascar** experienced rapid **infrastructure expansion**, particularly through **agent and ATM growth**.

### 4. SME Credit Trends
- The regional **median Loan-to-Deposit Ratio (LDR)** was **0.7 in 2024**, meaning $0.70 was lent for every $1 deposited.  
- **Namibia**’s LDR of **2.54** reflects **aggressive lending beyond deposits**. Despite liquidity concerns, banks remain **regulatorily compliant**, supported by strong central bank oversight.

### 5. Mobile User Maturity
- While registered accounts rose sharply, **active accounts declined significantly after 2022**, signaling **lower engagement**.  
- This points to **trust issues, high transaction costs**, or **digital engagement fatigue** across several markets.

### Recommendations

- Banks should pivot toward mobile money partnerships and interoperable platforms to remain competitive, particularly in underserved markets.
- Regulators and institutions should review financial inclusion frameworks, incentivize women-led enterprise funding, and ensure targeted lending programs.
- Focus investments in high-population, low-infrastructure markets (e.g., Madagascar) and saturated but underperforming systems (Namibia, Zimbabwe).
- Maintain LDR ratios within the 0.7–0.9 range to ensure liquidity and support SME sector growth sustainably.
- Encourage mobile activity through reduced transaction fees, loyalty programs, and simplified digital onboarding, especially in markets in need of recovery.

### Limitations & Assumptions of Analysis
- Some data gaps may affect accuracy of insights.  
- The time period was limited to 2020–2024 for recency and manageability of the analysis.  
- South Africa’s 2024 data was unavailable.  
- Data entry inconsistencies from source agencies may have influenced trend accuracy.  
- Broader global economic factors beyond COVID-19 were excluded for scope clarity.

---

## Further Analysis
