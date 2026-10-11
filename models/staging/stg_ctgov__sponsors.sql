with source as (
    select * from {{ source('ctgov', 'sponsors') }}
)

select distinct
    nct_id,
    trim(sponsor_name) as sponsor_name,
    coalesce(nullif(sponsor_class, ''), 'UNKNOWN') as sponsor_class,
    sponsor_role
from source
where nullif(trim(sponsor_name), '') is not null
