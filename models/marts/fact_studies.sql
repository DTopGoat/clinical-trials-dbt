-- Grain: one row per completed interventional oncology study.
select
    s.nct_id,
    sp.sponsor_key as lead_sponsor_key,
    s.brief_title,
    s.phase,
    s.allocation,
    s.intervention_model,
    s.primary_purpose,
    s.masking,
    s.lead_sponsor_class,
    s.enrollment_count,
    s.enrollment_type,
    s.start_date,
    s.start_year,
    s.primary_completion_date,
    s.completion_date,
    s.results_first_posted_date,
    s.has_results,
    s.days_to_primary_completion,
    s.days_to_completion,
    s.days_completion_to_results,
    s.site_count,
    s.country_count,
    s.condition_count,
    s.intervention_count,
    s.has_drug_intervention
from {{ ref('int_studies__enriched') }} as s
left join {{ ref('int_sponsors__deduplicated') }} as sp
    on s.lead_sponsor_name = sp.sponsor_name
