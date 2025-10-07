{{
    config(
        materialized='table'
    )
}}

{% set start_date = var('shopify__calendar_start_date', '2019-01-01') %}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ start_date ~ "' as date)",
        end_date="dateadd(year, 1, current_date)"
    ) }}

)

select
    date_day
from date_spine
