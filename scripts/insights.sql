-- 1. Studies, enrollment and median duration by phase
select phase, count(*) studies, sum(enrollment_count) participants,
       median(enrollment_count) median_enroll, round(median(days_to_completion)/30.4,1) median_months
from marts.fact_studies group by 1 order by studies desc;
-- 2. Results-posting rate by sponsor class
select lead_sponsor_class, count(*) studies, round(100*avg(has_results::int),1) pct_results,
       median(days_completion_to_results) median_days_to_results
from marts.fact_studies group by 1 having count(*) >= 40 order by studies desc;
-- 3. Top lead sponsors
select sponsor_name, sponsor_class, studies_as_lead from marts.dim_sponsors order by 3 desc limit 10;
-- 4. Top countries by study count
select country, count(distinct nct_id) studies, count(*) study_sites
from marts.fact_study_sites group by 1 order by 2 desc limit 10;
-- 5. Top conditions
select condition_display_name, study_count from marts.dim_conditions order by 2 desc limit 10;
