-- Exploratory Data Analysis

select *
from layoffs_staging2
;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2
;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select min(`date`), max(`date`) 
from layoffs_staging2;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

select industry, avg(percentage_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with rolling_total as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) tlf
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, tlf, sum(tlf) over(order by `month`) rt
from rolling_total;


select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

with company_year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
),
company_year_rank as
(
select *, dense_rank() over(partition by years order by total_laid_off desc) ranking 
from company_year
where years is not null
)
select *
from company_year_rank
where ranking <= 5
;
create temporary table total_employees
select *, (total_laid_off/percentage_laid_off) as total_emp
from layoffs_staging2
where percentage_laid_off > 0;

select company, country, total_emp, year(`date`) years, total_laid_off, percentage_laid_off
from total_employees
where total_emp is not null
order by company;

with Rank_CTE as
(
select company, location, country, total_emp as te, year(`date`) years, total_laid_off, percentage_laid_off
from total_employees
),
Employee_Rank as
(
select *, dense_rank() over(partition by years order by te desc) total_emprank
from Rank_CTE
where years is not null
)
select *
from Employee_rank
where total_emprank <= 5
order by 5 desc;
