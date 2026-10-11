with source as (
    select * from {{ source('ctgov', 'conditions') }}
)

select distinct
    nct_id,
    trim(condition_name) as condition_name,
    lower(regexp_replace(trim(condition_name), '\s+', ' ', 'g')) as condition_name_normalized
from source
where nullif(trim(condition_name), '') is not null
