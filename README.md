# Tech Layoffs Data Cleaning in SQL

## Project Overview
This repository contains a comprehensive SQL script used to clean and standardize a raw dataset of global tech layoffs. The goal of this project is to transform messy, inconsistent data into a reliable, structured format ready for exploratory data analysis (EDA) and visualization.

## Key SQL Skills Demonstrated
- **Advanced Querying:** Common Table Expressions (CTEs) and Window Functions (`ROW_NUMBER()`).
- **Data Manipulation Language (DML):** `INSERT`, `UPDATE`, `DELETE` operations.
- **Data Definition Language (DDL):** Creating staging tables and altering table schemas (`ALTER TABLE`, `MODIFY COLUMN`).
- **Data Cleaning Techniques:** Deduplication, string formatting (`TRIM`, `TRAILING`), and data type conversions (`STR_TO_DATE`).

## The Data Cleaning Workflow
The script (`layoffs_data_cleaning.sql`) follows a structured, step-by-step methodology:

1. **Workspace Preparation:** Created identical staging tables (`layoffs_stagging` and `layoffs_stagging2`) to protect the raw data from accidental deletion or corruption.
2. **Duplicate Removal:** Built a CTE using `ROW_NUMBER()` partitioned across all columns to identify and safely delete duplicate records.
3. **Data Standardization:** 
   - Trimmed whitespace from company names.
   - Merged inconsistent industry labels (e.g., standardizing various crypto labels into a single 'Crypto' category).
   - Cleaned geographic data by removing trailing punctuation from country names.
4. **Data Type Conversion:** Transformed the text-based `date` column into a standard SQL `DATE` format for accurate time-series analysis.
5. **Handling Missing Values:** Safely removed records where critical metrics (total laid off AND percentage laid off) were both missing, as they provided no analytical value.

## Conclusion
By executing this script, the raw dataset is transformed into a clean, highly reliable table (`layoffs_stagging2`) that can be confidently connected to visualization tools like Tableau or Power BI, or queried further for statistical insights.
