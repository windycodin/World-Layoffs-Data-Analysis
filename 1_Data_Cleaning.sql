-- Data Cleaning

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Unneccessary Columns or Rows

-- Creating a staging table to keep the raw data safe
CREATE TABLE layoffs_staging
LIKE layoffs; 

SELECT * 
FROM layoffs_staging;


INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- Checking my work to verify the duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
 industry, total_laid_off, percentage_laid_off, `date`, stage
 , country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
 industry, total_laid_off, percentage_laid_off, `date`, stage
 , country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE 
FROM duplicate_cte
WHERE row_num > 1;

-- Removing Duplicates
-- MySQL does not allow deleting directly from a CTE snapshots
-- Therefore we must create a secondary staging table with a physicalk 'row_num' column

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
 industry, total_laid_off, percentage_laid_off, `date`, stage
 , country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Deleting all duplicate rows higher than row_num 1

DELETE
FROM layoffs_staging2
WHERE row_num > 1;


SELECT *
FROM layoffs_staging2;


-- Standardizing data (finding issues and fixing it.)
-- (eg. spaces front of the names or etc)

SELECT company, TRIM(company)
FROM layoffs_staging2;

-- Removing leading/trailing spaces from company names by using TRIM 
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Updating the name of alike industries and combining them into one 
-- So when we visualize or create a visualization 
-- they won't have their own place and will be combined into one category

-- Since Crypto has duplicates we group them into a single industry name
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- If we are trying to do time series , exploratory data analysis,
-- Visualization the date needs to be changed text to date column
-- Therefore converted string dates to standard DATE formats
SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

-- Only do this down below on duplicate table never on original data / We will modify it
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT * 
FROM layoffs_staging2;

-- Fixing the NULL parts 
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- First attempt at populating missing industry data
UPDATE layoffs_staging2 t1
JOIN layoffs_staging t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL 
OR industry = '';

SELECT * 
FROM layoffs_staging2 
WHERE company = 'Airbnb';

-- Populate missing industry data by matching with identical companies using a Self-Join
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL 
AND t2.industry != '';

SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL 
OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2;

-- Remove Unnecessary Columns and Rows

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Droping the temporary row_num columns since duplicates are already removed. 
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- So far until here we removed duplicates first we created a duplicate of the data to keep the main data safe
-- Then we created another duplicate of the duplicate because MySQL did not let us delete CTE snapshots
-- Therefore  we had to create another duplicate then we deleted every duplicates which is higher than row1