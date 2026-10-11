select distinct
    l.nct_id,
    {{ dbt_utils.generate_surrogate_key(['l.facility', 'l.city', 'l.state', 'l.country']) }} as site_key,
    l.country
from {{ ref('stg_ctgov__locations') }} as l
