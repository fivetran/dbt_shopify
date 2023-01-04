with order_line as (

    select *
    from {{ var('shopify_order_line') }}
),

order as (

    select *
    from {{ var('shopify_order') }}
    where not coalesce(is_deleted, false)
), 

{% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), refunds_aggregated as (
    
    select
        order_line_id,
        source_relation,
        sum(quantity) as quantity,
        sum(coalesce(subtotal, 0)) as subtotal

    from refunds
    group by 1,2
),
{% endif %}

joined as (

    select
        order_line.order_line_id,
        order_line.variant_id,
        order_line.source_relation,
        order.location_id,
        order.order_id,
        order.customer_id,
        lower(order.email) as email,
        order_line.pre_tax_price,
        order_line.quantity,
        order.created_timestamp as order_created_timestamp

        {%- if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) -%}
        , refunds_aggregated.subtotal as subtotal_sold_refunds
        , refunds_aggregated.quantity as quantity_sold_refunds
        {% endif %}

    from order_line 
    join order 
        on order_line.order_id = order.order_id
        and order_line.source_relation = order.source_relation

    {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
    left join refunds_aggregated
        on refunds_aggregated.order_line_id = order_line.order_line_id
        and refunds_aggregated.source_relation = order_line.source_relation
    {% endif %}
),

aggregated as (

    select
        variant_id,
        location_id,
        source_relation,
        sum(pre_tax_price) as subtotal_sold,
        sum(quantity) as quantity_sold,
        count(distinct order_id) as count_distinct_orders,
        count(distinct customer_id) as count_distinct_customers,
        count(distinct email) as count_distinct_customer_emails,
        min(order_created_timestamp) as first_order_timestamp,
        max(order_created_timestamp) as last_order_timestamp

        {%- if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) -%}
        , coalesce(subtotal_sold_refunds, 0) as subtotal_sold_refunds
        , coalesce(quantity_sold_refunds, 0) as quantity_sold_refunds
        {% endif %}

    from joined
)

select *
from aggregated