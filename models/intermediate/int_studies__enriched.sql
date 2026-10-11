-- Study grain: normalizes phase, derives durations and per-study counts.
with studies as (
    select * from {{ ref('stg_ctgov__studies') }}
),

site_counts as (
    select
        nct_id,
        count(*) as site_count,
        count(distinct country) as country_count
    from {{ ref('stg_ctgov__locations') }}
    group by 1
),

condition_counts as (
    select
        nct_id,
        count(*) as condition_count
    from {{ ref('stg_ctgov__conditions') }}
    group by 1
),

intervention_counts as (
    select
        nct_id,
        count(*) as intervention_count,
        bool_or(intervention_type = 'DRUG') as has_drug_intervention
    from {{ ref('stg_ctgov__interventions') }}
    group by 1
)

select
    s.*,
    case
        when s.phases_raw is null then 'NOT_APPLICABLE'
        when s.phases_raw = 'NA' then 'NOT_APPLICABLE'
        when s.phases_raw = 'EARLY_PHASE1' then 'EARLY_PHASE1'
        when s.phases_raw = 'PHASE1|PHASE2' then 'PHASE1/2'
        when s.phases_raw = 'PHASE2|PHASE3' then 'PHASE2/3'
        else s.phases_raw
    end as phase,
    date_diff('day', s.start_date, s.primary_completion_date) as days_to_primary_completion,
    date_diff('day', s.start_date, s.completion_date) as days_to_completion,
    date_diff('day', s.completion_date, s.results_first_posted_date) as days_completion_to_results,
    year(s.start_date) as start_year,
    coalesce(sc.site_count, 0) as site_count,
    coalesce(sc.country_count, 0) as country_count,
    coalesce(cc.condition_count, 0) as condition_count,
    coalesce(ic.intervention_count, 0) as intervention_count,
    coalesce(ic.has_drug_intervention, false) as has_drug_intervention
from studies as s
left join site_counts as sc using (nct_id)
left join condition_counts as cc using (nct_id)
left join intervention_counts as ic using (nct_id)
