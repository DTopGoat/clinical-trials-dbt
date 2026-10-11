with source as (
    select * from {{ source('ctgov', 'studies') }}
)

select
    nct_id,
    brief_title,
    overall_status,
    study_type,
    nullif(phases, '') as phases_raw,
    allocation,
    intervention_model,
    primary_purpose,
    masking,
    try_cast(enrollment_count as integer) as enrollment_count,
    enrollment_type,
    {{ parse_ctgov_date('start_date') }} as start_date,
    {{ parse_ctgov_date('primary_completion_date') }} as primary_completion_date,
    {{ parse_ctgov_date('completion_date') }} as completion_date,
    {{ parse_ctgov_date('first_posted_date') }} as first_posted_date,
    {{ parse_ctgov_date('results_first_posted_date') }} as results_first_posted_date,
    lower(has_results) = 'true' as has_results,
    trim(lead_sponsor_name) as lead_sponsor_name,
    lead_sponsor_class
from source
