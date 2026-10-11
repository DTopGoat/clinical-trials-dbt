-- Aggregated metrics for dashboards: enrollment and duration by phase and sponsor class.
select
    phase,
    lead_sponsor_class,
    count(*) as study_count,
    sum(enrollment_count) as total_enrollment,
    round(median(enrollment_count), 1) as median_enrollment,
    round(median(days_to_completion), 1) as median_days_to_completion,
    round(median(days_to_primary_completion), 1) as median_days_to_primary_completion,
    round(avg(case when has_results then 1.0 else 0.0 end), 4) as pct_with_results,
    round(median(days_completion_to_results), 1) as median_days_completion_to_results
from {{ ref('fact_studies') }}
group by 1, 2
