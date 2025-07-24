{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with discounts_enriched as (

    select *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'discount_code_id']) }} as discounts_unique_key
    from {{ ref('int_shopify_gql__discount_code_enriched')}}
),

orders_aggregated as (

    select *
    from {{ ref('int_shopify_gql__discounts__order_aggregates')}}
),

{% if var('shopify_gql_using_abandoned_checkout', True) %}
abandoned_checkouts_aggregated as (

    select *
    from {{ ref('int_shopify_gql__discounts__abandoned_checkouts')}}
),
{% endif %}


aggregates_joined as (

    select 
        discounts_enriched.*,
        {# application_type is deprecated and not included - should i set a null field? #}
        coalesce(orders_aggregated.count_orders, 0) as count_orders,
        orders_aggregated.avg_order_discount_amount,
        coalesce(orders_aggregated.total_order_discount_amount, 0) as total_order_discount_amount,
        coalesce(orders_aggregated.total_order_line_items_price, 0) as total_order_line_items_price,
        coalesce(orders_aggregated.total_order_shipping_cost, 0) as total_order_shipping_cost,
        coalesce(orders_aggregated.total_order_refund_amount, 0) as total_order_refund_amount,
        coalesce(orders_aggregated.count_customers, 0) as count_customers,
        coalesce(orders_aggregated.count_customer_emails, 0) as count_customer_emails
        
        {% if var('shopify_gql_using_abandoned_checkout', True) %}
        , coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_discount_amount, 0) as total_abandoned_checkout_discount_amount,
        {# coalesce(abandoned_checkouts_aggregated.total_abandoned_checkout_shipping_price, 0) as total_abandoned_checkout_shipping_price, #}
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkouts, 0) as count_abandoned_checkouts,
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkout_customers, 0) as count_abandoned_checkout_customers,
        coalesce(abandoned_checkouts_aggregated.count_abandoned_checkout_customer_emails, 0) as count_abandoned_checkout_customer_emails
        {% endif %} 

    from discounts_enriched
    left join orders_aggregated
        on discounts_enriched.code = orders_aggregated.code
        and discounts_enriched.source_relation = orders_aggregated.source_relation
        -- in case one CODE can apply to both shipping and line items, percentages and fixed_amounts
        and (case 
                when discounts_enriched.target_type = 'shipping_line' then 'shipping' -- when target_type = 'shipping', value_type = 'percentage'
                else discounts_enriched.value_type end) = orders_aggregated.type

    {% if var('shopify_gql_using_abandoned_checkout', True) %}
    left join abandoned_checkouts_aggregated
        on discounts_enriched.code = abandoned_checkouts_aggregated.code
        and discounts_enriched.source_relation = abandoned_checkouts_aggregated.source_relation
        -- in case one CODE can apply to both shipping and line items, percentages and fixed_amounts
        and (case 
                when discounts_enriched.target_type = 'shipping_line' then 'shipping' -- when target_type = 'shipping', value_type = 'percentage'
                else discounts_enriched.value_type end) = abandoned_checkouts_aggregated.type
    {% endif %}
)

select * 
from aggregates_joined