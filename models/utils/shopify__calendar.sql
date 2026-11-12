{% set start_date = var('shopify__calendar_start_date', '2019-01-01') %}

with spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ start_date ~ "' as date)",
        end_date=dbt.dateadd("day", 0, "current_date")
        )
    }}
)

select cast(date_day as date) as date_day
from spine
