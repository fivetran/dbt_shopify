{{
    config(
        materialized='table',
        partition_by={
            "field": "date_month",
            "data_type": "date"
        },
        cluster_by=['date_month', 'customer_id']
    )
}}

with calendar as (

    select *
    from {{ ref('airshopify__calendar') }}
    where cast(date_day as date) = date_trunc(date_day, month)

), customers as (

    select *
    from {{ ref('airshopify__customers') }}

), orders as (

    select *
    from {{ ref('airshopify__orders') }}

), customer_calendar as (

    select
        cast(calendar.date_day as date) as date_month,
        customers.customer_id,
        customers.first_order_timestamp,
        customers.source_relation,
        cast(date_trunc(first_order_timestamp, month) as date) as cohort_month
    from calendar
    inner join customers
        on cast(date_trunc(first_order_timestamp, month) as date) <= calendar.date_day

), orders_joined as (

    select
        customer_calendar.date_month,
        customer_calendar.customer_id,
        customer_calendar.first_order_timestamp,
        customer_calendar.cohort_month,
        customer_calendar.source_relation,
        coalesce(count(distinct orders.order_id), 0) as order_count_in_month,
        coalesce(sum(orders.order_adjusted_total), 0) as total_price_in_month,
        coalesce(sum(orders.line_item_count), 0) as line_item_count_in_month
    from customer_calendar
    left join orders
        on customer_calendar.customer_id = orders.customer_id
        and customer_calendar.source_relation = orders.source_relation
        and customer_calendar.date_month = cast(date_trunc(created_timestamp, month) as date)
    group by 1, 2, 3, 4, 5

), windows as (

    select
        *,
        sum(total_price_in_month) over (
            partition by customer_id, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as total_price_lifetime,
        sum(order_count_in_month) over (
            partition by customer_id, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as order_count_lifetime,
        sum(line_item_count_in_month) over (
            partition by customer_id, source_relation
            order by date_month
            rows between unbounded preceding and current row
        ) as line_item_count_lifetime,
        row_number() over (
            partition by customer_id, source_relation
            order by date_month asc)
            as cohort_month_number
    from orders_joined

), final as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['date_month','customer_id','source_relation']) }} as customer_cohort_id
    from windows

)

select *
from final
