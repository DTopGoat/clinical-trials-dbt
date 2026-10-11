with source as (
    select * from {{ source('ctgov', 'interventions') }}
)

select distinct
    nct_id,
    coalesce(nullif(intervention_type, ''), 'OTHER') as intervention_type,
    trim(intervention_name) as intervention_name
from source
where nullif(trim(intervention_name), '') is not null
