select distinct
    c.nct_id,
    {{ dbt_utils.generate_surrogate_key(['c.condition_name_normalized']) }} as condition_key
from {{ ref('stg_ctgov__conditions') }} as c
