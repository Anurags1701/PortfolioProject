-- Data Cleaning

Select * from layoffs

-- 1. Removing duplicated
-- 2. Standardize the data
-- 3. NUll value or blank values
-- 4. Removing any uneccessary columns

Create table layoffs_staging
like layoffs;

select * from layoffs_staging;

Insert layoffs_staging 
select * from layoffs;

-- Removing dulicates

select *,
row_number() Over(
Partition By company,location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions) As row_num
from layoffs_staging;

with duplicate_cte AS
( select *,
row_number() Over(
Partition By company,location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions) As row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num>1;

select *
from layoffs_staging
where company='cazoo';



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
   `row_num`int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

Insert Into layoffs_staging2
select *,
row_number() Over(
Partition By company,location, industry, total_laid_off, percentage_laid_off, 'date',stage, country, funds_raised_millions) As row_num
from layoffs_staging;

select *
from layoffs_staging2
where row_num>1;

Delete 
from layoffs_staging2
where row_num>1;

-- Standardizing data

select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
set company= trim(company);

select distinct industry
from layoffs_staging2;

select * 
from layoffs_staging2
where industry like 'Crypto%';

Update layoffs_staging2
set industry= 'Crypto'
where industry like 'Crypto%';



select * 
from layoffs_staging2;

select distinct country
from layoffs_staging2
order by 1;

select * from layoffs_staging2
where country like 'United States%'
order by 1;

select distinct country, trim(Trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country= trim(Trailing '.' from country)
where country like 'United States%';

-- Updating date from text to date format

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

Update layoffs_staging2
SET `date`= str_to_date(`date`,'%m/%d/%Y');

select `date`
from layoffs_staging2;

Alter Table layoffs_staging2
Modify column `date` DATE;

-- Removing NULLS and blank spaces

select * from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

update layoffs_staging2
set industry= NULL 
where industry='';

select * from 
layoffs_staging2
where industry is null
or industry='';

select * from layoffs_staging2
where company like 'Bally%';

select distinct company
from layoffs_staging2
order by 1;

select t1.industry, t2.industry
from layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company= t2.company
where (t1.industry is null or t1.industry='')
AND t2.industry is not null;

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
AND t2.industry IS NOT NULL;



select * from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
AND percentage_laid_off is null;

Alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;