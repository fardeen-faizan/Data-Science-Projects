SELECT *
FROM layoffs;	

CREATE TABLE layoffs_cleaning
LIKE layoffs;
SELECT *
FROM layoffs_cleaning;


INSERT layoffs_cleaning
SELECT *
FROM layoffs;

WITH duplicates_layoffs AS(
	SELECT *,
    ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS num
    FROM layoffs_cleaning
)
SELECT *
FROM duplicates_layoffs
WHERE num>1;

CREATE TABLE duplicates_layoffs2 AS
SELECT * 
FROM (
	SELECT *,	
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS `row`
	FROM layoffs_cleaning
) AS t
WHERE `row` = 1;

SELECT *
FROM duplicates_layoffs2;

UPDATE duplicates_layoffs2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM duplicates_layoffs2;	

UPDATE duplicates_layoffs2
SET industry = "Crypto Currency"
WHERE industry LIKE "Crypto%";

SELECT DISTINCT(country)
FROM duplicates_layoffs2;

UPDATE duplicates_layoffs2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE "United States%";

UPDATE duplicates_layoffs2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE duplicates_layoffs2
MODIFY COLUMN `date` DATE;

SELECT t1.industry, t2.industry
FROM duplicates_layoffs2 t1 JOIN duplicates_layoffs2 t2 ON t1.company = t2.company 
WHERE (t1.industry = "" OR t1.industry = NULL)
;

UPDATE duplicates_layoffs2
SET industry = null
WHERE industry = " ";

UPDATE duplicates_layoffs2 t1
JOIN duplicates_layoffs2 t2 ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE (t1.industry = NULL) AND t2.industry IS NOT NULL;

DELETE
FROM duplicates_layoffs2
WHERE (total_laid_off = NULL) AND (percentage_laid_off = NULL)
;

ALTER TABLE duplicates_layoffs2
DROP COLUMN `row`; 

ALTER TABLE duplicates_layoffs2 RENAME TO cleaned_layoffs;

SELECT *
FROM cleaned_layoffs;