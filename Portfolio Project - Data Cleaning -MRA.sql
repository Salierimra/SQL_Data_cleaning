-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

SELECT * 
FROM world_layoffs.layoffs;

-- Creating staging TABLE
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs; -- copy all datas

INSERT layoffs_staging -- insert datas
SELECT * FROM world_layoffs.layoffs;


-- 1. Remove Duplicates

-- Creating a table staging 2 with adding the row_num
-- Right clic on table -> copy to clipboard -> create statement

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

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num -- creating an user_id don't forget that ladate is a data type
FROM layoffs_staging;

select *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardize Data

SELECT * 
FROM world_layoffs.layoffs_staging2;

select company,TRIM(company)
from layoffs_staging2;
UPDATE layoffs_staging2
SET company = TRIM(company);

-- the Crypto has different variations. all to Crypto
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- "United States" and some "United States." 
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- fix the date columns:
SELECT *
FROM world_layoffs.layoffs_staging2;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
-- convert the data type 
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. CHECK null and empty rows

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- On remarque qu'une autre entrée 'airbnb' a une industry travel -> on prends cette entrée comme resultat
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- set the blanks to nulls 
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- 4. remove any columns and rows we need to

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- No need to row_num
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Datas cleaned ;)
SELECT * 
FROM world_layoffs.layoffs_staging2;


































