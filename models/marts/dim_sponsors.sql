with sponsors as (
    select * from {{ ref('int_sponsors__deduplicated') }}
),

activity as (
    select
        sponsor_name,
        count(distinct case when sponsor_role = 'LEAD' then nct_id end) as studies_as_lead,
        count(distinct case when sponsor_role = 'COLLABORATOR' then nct_id end) as studies_as_collaborator
    from {{ ref('stg_ctgov__sponsors') }}
    group by 1
)

select
    s.sponsor_key,
    s.sponsor_name,
    s.sponsor_class,
    a.studies_as_lead,
    a.studies_as_collaborator
from sponsors as s
inner join activity as a using (sponsor_name)
