select
    {{ dbt_utils.generate_surrogate_key(['facility', 'city', 'state', 'country']) }} as site_key,
    facility,
    city,
    state,
    country,
    count(distinct nct_id) as study_count
from {{ ref('stg_ctgov__locations') }}
group by facility, city, state, country
