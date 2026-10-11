{# ClinicalTrials.gov dates are either YYYY-MM-DD or YYYY-MM; month-only dates resolve to the 1st. #}
{% macro parse_ctgov_date(col) -%}
    case
        when {{ col }} is null or trim({{ col }}) = '' then null
        when length(trim({{ col }})) = 7 then cast(trim({{ col }}) || '-01' as date)
        else try_cast(trim({{ col }}) as date)
    end
{%- endmacro %}
