with orders as (

    select *
    from {{ ref('salla_orders') }}

), customers as (

    select *
    from {{ ref('salla_customers') }}

), first_orders as (

    select
        customer_id,
        source_relation,
        min(cast(order_date as date)) as first_order_date,
        date_trunc(min(cast(order_date as date)), month) as cohort_month,
        date_trunc(min(cast(order_date as date)), year) as cohort_year
    from orders
    where customer_id is not null
    group by 1, 2

), cohort_data as (

    select
        orders.customer_id,
        orders.source_relation,
        first_orders.cohort_month,
        first_orders.cohort_year,
        date_trunc(cast(orders.order_date as date), month) as order_month,
        date_diff(date_trunc(cast(orders.order_date as date), month), first_orders.cohort_month, month) as months_since_first_order,
        count(distinct orders.order_id) as order_count,
        sum(orders.total_amount) as revenue
    from orders
    inner join first_orders
        on orders.customer_id = first_orders.customer_id
        and orders.source_relation = first_orders.source_relation
    group by 1, 2, 3, 4, 5, 6

), cohort_summary as (

    select
        cohort_month,
        cohort_year,
        source_relation,
        count(distinct customer_id) as cohort_size,
        sum(revenue) as total_cohort_revenue
    from cohort_data
    where months_since_first_order = 0
    group by 1, 2, 3

), final as (

    select
        cohort_data.cohort_month,
        cohort_data.cohort_year,
        cohort_data.source_relation,
        cohort_summary.cohort_size,
        cohort_summary.total_cohort_revenue,
        cohort_data.order_month,
        cohort_data.months_since_first_order,
        count(distinct cohort_data.customer_id) as customers_active,
        sum(cohort_data.order_count) as total_orders,
        sum(cohort_data.revenue) as period_revenue
    from cohort_data
    inner join cohort_summary
        on cohort_data.cohort_month = cohort_summary.cohort_month
        and cohort_data.source_relation = cohort_summary.source_relation
    group by 1, 2, 3, 4, 5, 6, 7

)

select *
from final
