-- A completed study cannot finish before it started.
select
    nct_id,
    start_date,
    completion_date
from {{ ref('fact_studies') }}
where completion_date < start_date
