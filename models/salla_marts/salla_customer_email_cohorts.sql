with email_rollup as (

    select *
    from {{ ref('int_salla__customer_email_rollup') }}

), orders as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.total_amount,
        orders.source_relation,
        customers.email
    from {{ ref('salla_orders') }} as orders
    left join {{ ref('stg_salla__customer') }} as customers
        on orders.customer_id = customers.customer_id
        and orders.source_relation = customers.source_relation
    where customers.email is not null

), first_orders as (

    select
        lower(email) as email,
        source_relation,
        min(cast(order_date as date)) as first_order_date,
        date_trunc(min(cast(order_date as date)), month) as cohort_month,
        date_trunc(min(cast(order_date as date)), year) as cohort_year
    from orders
    group by 1, 2

), cohort_data as (

    select
        lower(orders.email) as email,
        orders.source_relation,
        first_orders.cohort_month,
        first_orders.cohort_year,
        date_trunc(cast(orders.order_date as date), month) as order_month,
        date_diff(date_trunc(cast(orders.order_date as date), month), first_orders.cohort_month, month) as months_since_first_order,
        count(distinct orders.order_id) as order_count,
        sum(orders.total_amount) as revenue
    from orders
    inner join first_orders
        on lower(orders.email) = first_orders.email
        and orders.source_relation = first_orders.source_relation
    group by 1, 2, 3, 4, 5, 6

), cohort_summary as (

    select
        cohort_month,
        cohort_year,
        source_relation,
        count(distinct email) as cohort_size,
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
        count(distinct cohort_data.email) as emails_active,
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
