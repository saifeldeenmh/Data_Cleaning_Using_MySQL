-- ==============================================================================
-- PROJECT: Tech Layoffs Data Cleaning
-- PURPOSE: To clean, standardize, and prepare raw layoff data for analysis.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Phase 1: Create a Safe Staging Workspace
-- ------------------------------------------------------------------------------
-- It is best practice to never modify the raw data directly. 
-- Here, we create a staging table that mirrors the original 'layoffs' table.

SELECT * 
FROM layoffs;

CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT INTO layoffs_stagging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_stagging;

-- ------------------------------------------------------------------------------
-- Phase 2: Identify and Remove Duplicates
-- ------------------------------------------------------------------------------
-- Using a Common Table Expression (CTE) and Window Function (ROW_NUMBER) 
-- to identify exact duplicate rows across all data columns.

WITH duplicates_cte AS (
    SELECT *, 
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 
        `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_stagging
)
SELECT * 
FROM duplicates_cte
WHERE row_num > 1;

-- Creating a second staging table to safely delete the duplicates. 
-- We add a 'row_num' column to easily filter and drop the duplicated rows.

CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_stagging2
SELECT *, 
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_stagging;

-- Verify duplicates were flagged, then delete them
SELECT * 
FROM layoffs_stagging2
WHERE row_num > 1;

DELETE
FROM layoffs_stagging2
WHERE row_num > 1;

-- ------------------------------------------------------------------------------
-- Phase 3: Standardize Text Data
-- ------------------------------------------------------------------------------
-- Trimming whitespace from company names to ensure accurate aggregations later
UPDATE layoffs_stagging2
SET company = TRIM(company);

-- Unifying industry names (e.g., standardizing 'Crypto', 'Crypto Currency', etc. into one label)
UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Removing rows with missing industry data if they cannot be populated
DELETE
FROM layoffs_stagging2
WHERE industry IS NULL;

-- Standardizing country names by removing trailing periods (e.g., 'United States.' to 'United States')
UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- ------------------------------------------------------------------------------
-- Phase 4: Format and Convert Date Fields
-- ------------------------------------------------------------------------------
-- Converting the text-based 'date' column into standard SQL Date format
UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Removing records with missing dates, as temporal data is critical for this analysis
DELETE 
FROM layoffs_stagging2
WHERE `date` IS NULL;

-- Altering the table schema to officially change the column data type to DATE
ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;

-- ------------------------------------------------------------------------------
-- Phase 5: Handle Missing/Null Values
-- ------------------------------------------------------------------------------
-- Rows missing both total_laid_off and percentage_laid_off are effectively useless 
-- for layoff impact analysis, so we remove them.

DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- ------------------------------------------------------------------------------
-- Phase 6: Final Cleanup
-- ------------------------------------------------------------------------------
-- Dropping the temporary 'row_num' column as it is no longer needed after deduplication

ALTER TABLE layoffs_stagging2
DROP COLUMN row_num;

-- Final review of the cleaned dataset
SELECT *
FROM layoffs_stagging2;