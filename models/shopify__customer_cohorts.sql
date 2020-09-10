with calendar as (

    select *
    from {{ ref('shopify__calendar') }}
    where date_trunc('month', date_day) = date_day

), customers as (

    select *
    from {{ ref('shopify__customers') }}

), orders as (

    select *
    from {{ ref('shopify__orders') }}

), customer_calendar as (

    select
        calendar.date_day as date_month,
        customers.customer_id,
        customers.first_order_timestamp,
        date_trunc('month',first_order_timestamp) as cohort_month
    from calendar
    inner join customers
        on date_trunc('month', customers.first_order_timestamp) <= calendar.date_day

), orders_joined as (

    select 
        customer_calendar.date_month, 
        customer_calendar.customer_id, 
        customer_calendar.first_order_timestamp,
        customer_calendar.cohort_month,
        coalesce(count(orders.order_id), 0) as order_count_in_month,
        coalesce(sum(orders.total_price), 0) as total_price_in_month,
        coalesce(sum(orders.line_item_count), 0) as line_item_count_in_month
    from customer_calendar
    left join orders
        on customer_calendar.customer_id = orders.customer_id
        and customer_calendar.date_month = date_trunc('month', created_timestamp)::date
    group by 1,2,3,4

), windows as (

    {% set partition_string = 'partition by customer_id order by date_month rows between unbounded preceding and current row' %}

    select
        *,
        sum(total_price_in_month) over ({{ partition_string }}) as total_price_lifetime,
        sum(order_count_in_month) over ({{ partition_string }}) as order_count_lifetime,
        sum(line_item_count_in_month) over ({{ partition_string }}) as line_item_count_lifetime,
        row_number() over (partition by customer_id order by date_month asc) as cohort_month_number
    from orders_joined
        
), surrogate_key as (

    select 
        *, 
        {{ dbt_utils.surrogate_key(['date_month','customer_id']) }} as customer_cohort_id
    from windows

)

select *
from surrogate_key