-- Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;



SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- 1 represents 100 in percentage_laid_off

-- Which companies had the most total layoffs?
SELECT company,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Which countries were impacted the most by layoffs?
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT * 
FROM layoffs_staging2;

-- Which years had the most layoffs?
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Which stage of funding (Seed, Series A, Post-IPO, etc.) saw the most layoffs?
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;


SELECT company, SUM(percentage_laid_off)
FROM layoff_staging_2
GROUP BY company 
ORDER BY 2 DESC;

-- Looking at layoffs month-by-month
SELECT SUBSTRING(`date` ,1,7) AS `MONTH` , SUM( total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;

WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date` ,1,7) AS `MONTH` , SUM( total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `Month`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`)
FROM Rolling_Total;






SELECT company, SUM(total_laid_off_)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- View total layoffs by company per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT *, DENSE_RANK() OVER ( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_Year_Rank
WHERE Ranking <= 5
;






