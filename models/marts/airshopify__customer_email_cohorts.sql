{{
    config(
        materialized='table',
        partition_by={
            "field": "date_month",
            "data_type": "date"
        },
        cluster_by=['date_month', 'email']
    )
}}

with calendar as (

    select *
    from {{ ref('airshopify__calendar') }}
    where cast(date_day as date) = date_trunc(date_day, month)

), customer_emails as (

    select *
    from {{ ref('airshopify__customer_emails') }}

), orders as (

    select *
    from {{ ref('airshopify__orders') }}

), customer_email_calendar as (

    select
        cast(calendar.date_day as date) as date_month,
        customer_emails.email,
        customer_emails.first_order_timestamp,
        customer_emails.source_relation,
        cast(date_trunc(first_order_timestamp, month) as date) as cohort_month
    from calendar
    inner join customer_emails
        on cast(date_trunc(first_order_timestamp, month) as date) <= calendar.date_day

), orders_joined as (

    select
        customer_email_calendar.date_month,
        customer_email_calendar.email,
        customer_email_calendar.first_order_timestamp,
        customer_email_calendar.cohort_month,
        customer_email_calendar.source_relation,
        coalesce(count(distinct orders.order_id), 0) as order_count_in_month,
        coalesce(sum(orders.order_adjusted_total), 0) as total_price_in_month,
        coalesce(sum(orders.line_item_count), 0) as line_item_count_in_month
    from customer_email_calendar
    left join orders
        on lower(customer_email_calendar.email) = lower(orders.email)
        and customer_email_calendar.source_relation = orders.source_relation
        and customer_email_calendar.date_month = cast(date_trunc(created_timestamp, month) as date)
    group by 1, 2, 3, 4, 5

), windows as (

    select
        *,
        sum(total_price_in_month) over (
            partition by email, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as total_price_lifetime,
        sum(order_count_in_month) over (
            partition by email, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as order_count_lifetime,
        sum(line_item_count_in_month) over (
            partition by email, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as line_item_count_lifetime,
        row_number() over (
            partition by email, source_relation
            order by date_month asc)
            as cohort_month_number
    from orders_joined

), final as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_month','email','source_relation']) }} as customer_cohort_id
    from windows

)

select *
from final
