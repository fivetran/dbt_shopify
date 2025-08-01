{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with orders as (

    select *
    from {{ ref('shopify_gql__orders') }}

    where not coalesce(is_deleted, false)
),

order_lines as(

    select *
    from {{ ref('shopify_gql__order_lines') }}
),

order_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day','created_timestamp') }} as date) as date_day,
        count(distinct order_id) as count_orders,
        sum(coalesce(line_item_count, 0)) as count_line_items,
        avg(line_item_count) as avg_line_item_count,
        count(distinct customer_id) as count_customers,
        count(distinct email) as count_customer_emails,
        sum(coalesce(order_adjusted_total, 0)) as order_adjusted_total,
        avg(order_adjusted_total) as avg_order_value,
        sum(coalesce(shipping_cost_shop_amount, 0)) as shipping_cost,
        sum(coalesce(order_adjustment_amount, 0)) as order_adjustment_amount,
        sum(coalesce(order_adjustment_tax_amount, 0)) as order_adjustment_tax_amount,
        sum(coalesce(refund_subtotal, 0)) as refund_subtotal,
        sum(coalesce(refund_total_tax, 0)) as refund_total_tax,
        sum(coalesce(total_discounts_shop_amount, 0)) as total_discounts,
        avg(total_discounts_shop_amount) as avg_discount,
        sum(coalesce(shipping_discount_amount, 0)) as shipping_discount_amount,
        avg(shipping_discount_amount) as avg_shipping_discount_amount,
        sum(coalesce(percentage_calc_discount_amount, 0)) as percentage_calc_discount_amount,
        avg(percentage_calc_discount_amount) as avg_percentage_calc_discount_amount,
        sum(coalesce(fixed_amount_discount_amount, 0)) as fixed_amount_discount_amount,
        avg(fixed_amount_discount_amount) as avg_fixed_amount_discount_amount,
        sum(coalesce(count_discount_codes_applied, 0)) as count_discount_codes_applied,
        count(distinct location_id) as count_locations_ordered_from,
        sum(coalesce(case when count_discount_codes_applied > 0 then 1 else 0 end, 0)) as count_orders_with_discounts,
        sum(coalesce(case when refund_subtotal > 0 then 1 else 0 end, 0)) as count_orders_with_refunds,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as last_order_timestamp

    from orders
    group by 1,2

),

order_line_aggregates as (

    select
        order_lines.source_relation,
        cast({{ dbt.date_trunc('day','orders.created_timestamp') }} as date) as date_day,
        sum(coalesce(order_lines.quantity, 0)) as quantity_sold,
        sum(coalesce(order_lines.refunded_quantity, 0)) as quantity_refunded,
        sum(coalesce(order_lines.quantity_net_refunds, 0)) as quantity_net,
        sum(coalesce(order_lines.quantity, 0)) / count(distinct order_lines.order_id) as avg_quantity_sold,
        sum(coalesce(order_lines.quantity_net_refunds, 0)) / count(distinct order_lines.order_id) as avg_quantity_net,
        count(distinct order_lines.variant_id) as count_variants_sold, 
        count(distinct order_lines.product_id) as count_products_sold, 
        sum(coalesce(case when order_lines.is_gift_card then order_lines.quantity_net_refunds else 0 end, 0)) as quantity_gift_cards_sold,
        sum(coalesce(case when order_lines.is_shipping_required then order_lines.quantity_net_refunds else 0 end, 0)) as quantity_requiring_shipping

    from order_lines
    left join orders -- just joining with order to get the created_timestamp
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation

    group by 1,2
),

final as (

    select 
        order_aggregates.*,
        order_line_aggregates.quantity_sold,
        order_line_aggregates.quantity_refunded,
        order_line_aggregates.quantity_net,
        order_line_aggregates.count_variants_sold,
        order_line_aggregates.count_products_sold,
        order_line_aggregates.quantity_gift_cards_sold,
        order_line_aggregates.quantity_requiring_shipping,
        order_line_aggregates.avg_quantity_sold,
        order_line_aggregates.avg_quantity_net

    from order_aggregates
    left join order_line_aggregates
        on order_aggregates.date_day = order_line_aggregates.date_day
        and order_aggregates.source_relation = order_line_aggregates.source_relation
)

select *
from final