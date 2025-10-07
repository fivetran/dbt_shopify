with orders as (

    select * from {{ ref('shopify__orders') }}

), order_lines as (

    select * from {{ ref('shopify__order_lines') }}

), aggregated as (

    select
        cast(orders.created_timestamp as date) as date_day,
        orders.source_relation,

        -- order counts
        count(distinct orders.order_id) as count_orders,
        count(distinct order_lines.order_line_id) as count_line_items,
        avg(order_lines.index) as avg_line_item_count,
        count(distinct orders.customer_id) as count_customers,
        count(distinct orders.email) as count_customer_emails,

        -- amounts
        sum(orders.order_adjusted_total) as order_adjusted_total,
        avg(orders.total_price) as avg_order_value,
        sum(orders.shipping_cost) as shipping_cost,
        sum(orders.order_adjustment_amount) as order_adjustment_amount,
        sum(orders.order_adjustment_tax_amount) as order_adjustment_tax_amount,
        sum(orders.refund_subtotal) as refund_subtotal,
        sum(orders.refund_total_tax) as refund_total_tax,

        -- discounts
        sum(orders.total_discounts) as total_discounts,
        avg(orders.total_discounts) as avg_discount,
        sum(orders.shipping_discount_amount) as shipping_discount_amount,
        avg(orders.shipping_discount_amount) as avg_shipping_discount_amount,
        sum(orders.percentage_calc_discount_amount) as percentage_calc_discount_amount,
        avg(orders.percentage_calc_discount_amount) as avg_percentage_calc_discount_amount,
        sum(orders.fixed_amount_discount_amount) as fixed_amount_discount_amount,
        avg(orders.fixed_amount_discount_amount) as avg_fixed_amount_discount_amount,
        sum(orders.count_discount_codes_applied) as count_discount_codes_applied,

        -- locations and refunds
        count(distinct orders.location_id) as count_locations_ordered_from,
        sum(case when orders.count_discount_codes_applied > 0 then 1 else 0 end) as count_orders_with_discounts,
        sum(case when orders.refund_subtotal > 0 then 1 else 0 end) as count_orders_with_refunds,

        -- timestamps
        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as last_order_timestamp,

        -- quantities
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.refunded_quantity) as quantity_refunded,
        sum(order_lines.quantity_net_refunds) as quantity_net,
        avg(order_lines.quantity) as avg_quantity_sold,
        avg(order_lines.quantity_net_refunds) as avg_quantity_net,
        count(distinct order_lines.variant_id) as count_variants_sold,
        count(distinct order_lines.product_id) as count_products_sold,
        sum(case when order_lines.is_gift_card then order_lines.quantity else 0 end) as quantity_gift_cards_sold,
        sum(case when order_lines.is_shipping_required then order_lines.quantity else 0 end) as quantity_requiring_shipping

    from orders
    left join order_lines
        on orders.order_id = order_lines.order_id
        and orders.source_relation = order_lines.source_relation

    group by 1, 2

)

select * from aggregated
