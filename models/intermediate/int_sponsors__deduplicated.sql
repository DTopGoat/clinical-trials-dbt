-- One row per sponsor organization; class resolved to the most frequent value.
with sponsors as (
    select * from {{ ref('stg_ctgov__sponsors') }}
),

ranked as (
    select
        sponsor_name,
        sponsor_class,
        count(*) as n,
        row_number() over (partition by sponsor_name order by count(*) desc, sponsor_class) as rn
    from sponsors
    group by 1, 2
)

select
    {{ dbt_utils.generate_surrogate_key(['sponsor_name']) }} as sponsor_key,
    sponsor_name,
    sponsor_class
from ranked
where rn = 1
