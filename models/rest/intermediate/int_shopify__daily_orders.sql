{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with orders as (

    select *
    from {{ ref('shopify__orders') }}

    where not coalesce(is_deleted, false)
),

order_refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

),

refunds as (

    select *
    from {{ ref('stg_shopify__refund') }}

),

order_adjustments as (

    select *
    from {{ ref('stg_shopify__order_adjustment') }}

),

order_lines as(

    select *
    from {{ ref('shopify__order_lines') }}
),

order_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day','created_timestamp') }} as date) as date_day,
        count(distinct order_id) as count_orders,
        sum(line_item_count) as count_line_items,
        avg(line_item_count) as avg_line_item_count,
        count(distinct customer_id) as count_customers,
        count(distinct email) as count_customer_emails,
        sum(order_adjusted_total) as order_adjusted_total,
        avg(order_adjusted_total) as avg_order_value,
        sum(shipping_cost) as shipping_cost,
        sum(order_adjustment_amount) as order_adjustment_amount,
        sum(order_adjustment_tax_amount) as order_adjustment_tax_amount,
        sum(total_discounts) as total_discounts,
        avg(total_discounts) as avg_discount,
        sum(shipping_discount_amount) as shipping_discount_amount,
        avg(shipping_discount_amount) as avg_shipping_discount_amount,
        sum(percentage_calc_discount_amount) as percentage_calc_discount_amount,
        avg(percentage_calc_discount_amount) as avg_percentage_calc_discount_amount,
        sum(fixed_amount_discount_amount) as fixed_amount_discount_amount,
        avg(fixed_amount_discount_amount) as avg_fixed_amount_discount_amount,
        sum(count_discount_codes_applied) as count_discount_codes_applied,
        count(distinct location_id) as count_locations_ordered_from,
        sum(case when count_discount_codes_applied > 0 then 1 else 0 end) as count_orders_with_discounts,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as last_order_timestamp,
        sum(gross_sales) as gross_sales,
        sum(discounts) as discounts,
        sum(net_sales) as net_sales

    from orders
    group by 1,2

),

refund_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day', 'created_at') }} as date) as date_day,
        sum(subtotal) as refund_subtotal,
        sum(total_tax) as refund_total_tax,
        count(distinct order_id) as count_orders_with_refunds,
        sum(case when not is_gift_card then coalesce(subtotal, 0) else 0 end) as refund_subtotal_non_gift_card
    from order_refunds
    group by 1, 2

),

refund_discrepancy_aggregates as (

    select
        refunds.source_relation,
        cast({{ dbt.date_trunc('day', 'refunds.created_at') }} as date) as date_day,
        sum(amount) as refund_discrepancy_amount
    from refunds 
    inner join order_adjustments
        on refunds.refund_id = order_adjustments.refund_id
        and refunds.source_relation = order_adjustments.source_relation
    where order_adjustments.kind = 'refund_discrepancy'
    group by 1, 2

),

order_line_aggregates as (

    select
        order_lines.source_relation,
        cast({{ dbt.date_trunc('day','orders.created_timestamp') }} as date) as date_day,
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.refunded_quantity) as quantity_refunded,
        sum(order_lines.quantity_net_refunds) as quantity_net,
        sum(order_lines.quantity) / count(distinct order_lines.order_id) as avg_quantity_sold,
        sum(order_lines.quantity_net_refunds) / count(distinct order_lines.order_id) as avg_quantity_net,
        count(distinct order_lines.variant_id) as count_variants_sold, 
        count(distinct order_lines.product_id) as count_products_sold, 
        sum(case when order_lines.is_gift_card then order_lines.quantity_net_refunds else 0 end) as quantity_gift_cards_sold,
        sum(case when order_lines.is_shipping_required then order_lines.quantity_net_refunds else 0 end) as quantity_requiring_shipping

    from order_lines
    left join orders -- just joining with order to get the created_timestamp
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation

    group by 1,2
),

final as (

    select
        coalesce(order_aggregates.source_relation, refund_aggregates.source_relation) as source_relation,
        coalesce(order_aggregates.date_day, refund_aggregates.date_day) as date_day,
        coalesce(order_aggregates.count_orders, 0) as count_orders,
        coalesce(order_aggregates.count_line_items, 0) as count_line_items,
        order_aggregates.avg_line_item_count,
        coalesce(order_aggregates.count_customers, 0) as count_customers,
        coalesce(order_aggregates.count_customer_emails, 0) as count_customer_emails,
        coalesce(order_aggregates.order_adjusted_total, 0) as order_adjusted_total,
        order_aggregates.avg_order_value,
        coalesce(order_aggregates.shipping_cost, 0) as shipping_cost,
        coalesce(order_aggregates.order_adjustment_amount, 0) as order_adjustment_amount,
        coalesce(order_aggregates.order_adjustment_tax_amount, 0) as order_adjustment_tax_amount,
        coalesce(order_aggregates.total_discounts, 0) as total_discounts,
        order_aggregates.avg_discount,
        coalesce(order_aggregates.shipping_discount_amount, 0) as shipping_discount_amount,
        order_aggregates.avg_shipping_discount_amount,
        coalesce(order_aggregates.percentage_calc_discount_amount, 0) as percentage_calc_discount_amount,
        order_aggregates.avg_percentage_calc_discount_amount,
        coalesce(order_aggregates.fixed_amount_discount_amount, 0) as fixed_amount_discount_amount,
        order_aggregates.avg_fixed_amount_discount_amount,
        coalesce(order_aggregates.count_discount_codes_applied, 0) as count_discount_codes_applied,
        coalesce(order_aggregates.count_locations_ordered_from, 0) as count_locations_ordered_from,
        coalesce(order_aggregates.count_orders_with_discounts, 0) as count_orders_with_discounts,
        order_aggregates.first_order_timestamp,
        order_aggregates.last_order_timestamp,
        coalesce(order_aggregates.gross_sales, 0) as gross_sales,
        coalesce(order_aggregates.discounts, 0) as discounts,
        coalesce(order_aggregates.net_sales, 0) as net_sales,
        coalesce(refund_aggregates.refund_subtotal, 0) as refund_subtotal,
        coalesce(refund_aggregates.refund_total_tax, 0) as refund_total_tax,
        coalesce(refund_aggregates.count_orders_with_refunds, 0) as count_orders_with_refunds,
        coalesce(refund_aggregates.refund_subtotal_non_gift_card, 0)
            - coalesce(refund_discrepancy_aggregates.refund_discrepancy_amount, 0) as returns,
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
    full outer join refund_aggregates
        on order_aggregates.date_day = refund_aggregates.date_day
        and order_aggregates.source_relation = refund_aggregates.source_relation
    left join refund_discrepancy_aggregates
        on coalesce(order_aggregates.date_day, refund_aggregates.date_day) = refund_discrepancy_aggregates.date_day
        and coalesce(order_aggregates.source_relation, refund_aggregates.source_relation) = refund_discrepancy_aggregates.source_relation
    left join order_line_aggregates
        on coalesce(order_aggregates.date_day, refund_aggregates.date_day) = order_line_aggregates.date_day
        and coalesce(order_aggregates.source_relation, refund_aggregates.source_relation) = order_line_aggregates.source_relation
)

select *
from final