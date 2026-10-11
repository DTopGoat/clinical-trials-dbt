with source as (
    select * from {{ source('ctgov', 'locations') }}
)

select distinct
    nct_id,
    coalesce(nullif(trim(facility), ''), 'Unknown facility') as facility,
    nullif(trim(city), '') as city,
    nullif(trim(state), '') as state,
    coalesce(nullif(trim(country), ''), 'Unknown') as country
from source
