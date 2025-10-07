{{ config(materialized='table') }}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast(current_date() + interval 1 year as date)"
    )
    }}

), calculated as (

    select
        date_day,
        extract(year from date_day) as year_number,
        extract(month from date_day) as month_number,
        extract(dayofweek from date_day) as day_of_week,
        extract(dayofyear from date_day) as day_of_year,
        extract(week from date_day) as week_of_year,
        extract(quarter from date_day) as quarter_of_year,
        format_date('%B', date_day) as month_name,
        format_date('%A', date_day) as day_name

    from date_spine

)

select *
from calculated
