with orders as (

    select *
    from {{ var('shopify_order') }}

), transactions as (

    select *
    from {{ ref('shopify__transactions')}}
    where lower(status) = 'success'

), order_line as (

    select
        *
    from {{ ref('shopify__orders__order_line_aggregates')}}

), customer_tags as (

    select 
        *
    from {{ var('shopify_customer_tag' )}}

), aggregated as (

    select
        orders.customer_id,
        orders.source_relation,
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp,
        avg(case when lower(transactions.kind) in ('sale','capture') then transactions.currency_exchange_calculated_amount end) as average_order_value,
        sum(case when lower(transactions.kind) in ('sale','capture') then transactions.currency_exchange_calculated_amount end) as lifetime_total_spent,
        sum(case when lower(transactions.kind) in ('refund') then transactions.currency_exchange_calculated_amount end) as lifetime_total_refunded,

        -- start new columns
        avg(order_line.order_total_quantity) as average_quantity_per_order,
        sum(order_line.order_total_tax) as lifetime_total_tax,
        avg(order_line.order_total_tax) as average_tax_per_order,
        sum(order_line.order_total_discount) as lifetime_total_discount,
        avg(order_line.order_total_discount) as average_discount_per_order,
        sum(order_line.order_total_shipping) as lifetime_total_shipping,
        avg(order_line.order_total_shipping) as average_shipping_per_order,
        sum(order_line.order_total_shipping_with_discounts) as lifetime_total_shipping_with_discounts,
        avg(order_line.order_total_shipping_with_discounts) as average_shipping_with_discounts_per_order,
        sum(order_line.order_total_shipping_tax) as lifetime_total_shipping_tax,
        avg(order_line.order_total_shipping_tax) as average_shipping_tax_per_order,
        {{ fivetran_utils.string_agg("distinct cast(customer_tags.value as " ~ dbt.type_string() ~ ")", "', '") }} as customer_tags,
        {# sum(abandoned.abandoned_checkouts) as lifetime_abandoned_checkouts  #}

    from orders
    left join transactions
        on orders.order_id = transactions.order_id
        and orders.source_relation = transactions.source_relation
    left join order_line
        on orders.order_id = order_line.order_id
        and orders.source_relation = order_line.source_relation
    left join customer_tags
        on orders.customer_id = customer_tags.customer_id
        and orders.source_relation = customer_tags.source_relation
    where orders.customer_id is not null
    group by 1,2

)

select *
from aggregated