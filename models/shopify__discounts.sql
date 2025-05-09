with discount as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'discount_code_id']) }} as discounts_unique_key
    from {{ var('shopify_discount_code') }}
),

price_rule as (

    select *
    from {{ var('shopify_price_rule') }}
),

discounts_enriched as (

    select *
    from {{ var('int_shopify__discount_code_enriched')}}
),

orders_aggregated as (

    select *
    from {{ ref('int_shopify__discounts__order_aggregates')}}
),

{% if var('shopify_using_abandoned_checkout', True) %}
abandoned_checkouts_aggregated as (

    select *
    from {{ ref('int_shopify__discounts__abandoned_checkouts')}}
),
{% endif %}

discount_enriched_joined as (

    select
        discount.*,
        discounts_enriched.target_selection,
        discounts_enriched.target_type,
        discounts_enriched.title,
        discounts_enriched.usage_limit,
        discounts_enriched.value,
        discounts_enriched.value_type,
        discounts_enriched.allocation_limit,
        discounts_enriched.allocation_method,
        discounts_enriched.is_once_per_customer,
        discounts_enriched.customer_selection, 
        discounts_enriched.starts_at,
        discounts_enriched.ends_at,
        discounts_enriched.created_at as discount_created_at,
        discounts_enriched.updated_at as discount_updated_at

    from discount
    left join discounts_enriched
        on discount.discount_code_id = discounts_enriched.discount_code_id
        and discount.source_relation = discounts_enriched.source_relation
),

aggregates_joined as (

    select 
        discount_enriched_joined.*,
        coalesce(orders_aggregated.count_orders, 0) as count_orders,
        orders_aggregated.avg_order_discount_amount,
        coalesce(orders_aggregated.total_order_discount_amount, 0) as total_order_discount_amount,
        coalesce(orders_aggregated.total_order_line_items_price, 0) as total_order_line_items_price,
        coalesce(orders_aggregated.total_order_shipping_cost, 0) as total_order_shipping_cost,
        coalesce(orders_aggregated.total_order_refund_amount, 0) as total_order_refund_amount,
        coalesce(orders_aggregated.count_customers, 0) as count_customers,
        coalesce(orders_aggregated.count_customer_emails, 0) as count_customer_emails
        
        {% if var('shopify_using_abandoned_checkout', True) %}
        , coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_discount_amount, 0) as total_abandoned_checkout_discount_amount,
        coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_shipping_price, 0) as total_abandoned_checkout_shipping_price,
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkouts, 0) as count_abandoned_checkouts,
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkout_customers, 0) as count_abandoned_checkout_customers,
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkout_customer_emails, 0) as count_abandoned_checkout_customer_emails
        {% endif %} 

    from discount_enriched_joined
    left join orders_aggregated
        on discount_enriched_joined.code = orders_aggregated.code
        and discount_enriched_joined.source_relation = orders_aggregated.source_relation
        -- in case one CODE can apply to both shipping and line items, percentages and fixed_amounts
        and (case 
                when discount_enriched_joined.target_type = 'shipping_line' then 'shipping' -- when target_type = 'shipping', value_type = 'percentage'
                else discount_enriched_joined.value_type end) = orders_aggregated.type

    {% if var('shopify_using_abandoned_checkout', True) %}
    left join abandoned_checkouts_aggregated
        on discount_enriched_joined.code = abandoned_checkouts_aggregated.code
        and discount_enriched_joined.source_relation = abandoned_checkouts_aggregated.source_relation
        -- in case one CODE can apply to both shipping and line items, percentages and fixed_amounts
        and (case 
                when discount_enriched_joined.target_type = 'shipping_line' then 'shipping' -- when target_type = 'shipping', value_type = 'percentage'
                else discount_enriched_joined.value_type end) = abandoned_checkouts_aggregated.type
    {% endif %}
)

select * 
from aggregates_joined