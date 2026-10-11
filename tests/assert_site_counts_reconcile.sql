-- site_count on fact_studies must equal the rows in fact_study_sites for each study.
with f as (
    select
        nct_id,
        site_count
    from {{ ref('fact_studies') }}
),

s as (
    select
        nct_id,
        count(*) as n
    from {{ ref('fact_study_sites') }}
    group by 1
)

select
    f.nct_id,
    f.site_count,
    coalesce(s.n, 0) as bridge_count
from f left join s using (nct_id)
where f.site_count <> coalesce(s.n, 0)
