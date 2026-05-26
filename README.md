# World Layoffs Data Analysis (SQL)
## Project Overview
This project focuses on cleaning and analyzing a real-world dataset of global tech layoffs. The goal of this project was to transform raw, messy data into a structured format and then perform Exploratory Data Analysis (EDA) to uncover business insights.

**Note:** This project was built following an excellent tutorial by Alex The Analyst. I used this tutorial to solidify my understanding of advanced SQL concepts like Common Table Expressions (CTEs), Window Functions, and Data Standardization. The code includes my personal notes, troubleshooting steps, and logic breakdowns.


## Project Structure
This repository contains two main SQL scripts:
### 1. `1_Data_Cleaning.sql`
* **Removing Duplicates:** Used `ROW_NUMBER()` and `PARTITION BY` to identify and safely remove duplicate entries by utilizing a secondary staging table to bypass MySQL's CTE deletion limits.
* **Standardizing Data:** Used `TRIM()` to fix string formatting, consolidated fragmented industry labels (e.g., various "Crypto" inputs), and used `STR_TO_DATE()` to convert text strings into standard time-series `DATE` data types.
* **Handling Missing Data:** Used a Self-Join to populate `NULL` industry values by matching them with known data from identical companies.
* **Removing Useless Rows:** Cleared out rows that lacked essential metrics (both total laid off and percentage laid off were null).

### 2. `2_Exploratory_Data_Analysis.sql`
With a clean dataset, I explored the data to find trends and outliers:
* **Basic Aggregations:** Identified which companies, industries, and countries were hit the hardest by layoffs.
* **Time Series Analysis:** Extracted month-by-month data and used a CTE with a Window Function (`SUM(...) OVER(...)`) to calculate the rolling total of layoffs over time.
* **Advanced Ranking:** Used multiple CTEs and the `DENSE_RANK()` window function to dynamically identify the top 5 companies with the most layoffs for each specific year.

* ## Key SQL Skills Demonstrated
* **Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, `OVER(PARTITION BY ...)`
* **Joins:** Self-Joins
* **Data Types:** String manipulation (`TRIM`, `SUBSTRING`), Date conversion (`STR_TO_DATE`, `YEAR`)
* **Aggregations:** `GROUP BY`, `SUM()`, `MIN()`, `MAX()`
* **Database Architecture:** Creating and inserting data into staging tables to protect raw datasets.
