select
    s.nct_id,
    {{ dbt_utils.generate_surrogate_key(['s.sponsor_name']) }} as sponsor_key,
    s.sponsor_role
from {{ ref('stg_ctgov__sponsors') }} as s
group by 1, 2, 3
