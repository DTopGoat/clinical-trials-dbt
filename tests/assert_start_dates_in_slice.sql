-- Every study must fall inside the extracted slice window.
select
    nct_id,
    start_date
from {{ ref('fact_studies') }}
where start_date < date '2015-01-01' or start_date > date '2016-12-31'
