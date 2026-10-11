select
    {{ dbt_utils.generate_surrogate_key(['condition_name_normalized']) }} as condition_key,
    condition_name_normalized as condition_name,
    min(condition_name) as condition_display_name,
    count(distinct nct_id) as study_count
from {{ ref('stg_ctgov__conditions') }}
group by condition_name_normalized
