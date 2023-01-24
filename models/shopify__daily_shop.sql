with shop as (

    select *
    from {{ var('shopify_shop') }}
),

calendar as (

    select *
    from {{ ref('shopify__calendar') }}
    where cast({{ dbt.date_trunc('day','date_day') }} as date) = date_day

),

shop_calendar as (

    select
        cast({{ dbt.date_trunc('day','calendar.date_day') }} as date) as date_day,
        shop.shop_id,
        shop.name,
        shop.domain,
        shop.is_deleted,
        shop.currency,
        shop.enabled_presentment_currencies,
        shop.iana_timezone,
        shop.created_at,
        shop.source_relation

    from calendar
    join shop 
        on cast(shop.created_at as date) <= calendar.date_day
),

orders as (

    select *
    from {{ ref('shopify__orders') }}

    where not coalesce(is_deleted, false)
),

order_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day','created_timestamp') }} as date) as date_day,
        count(distinct order_id) as count_orders,
        sum(line_item_count) as count_line_items,
        count(distinct customer_id) as count_customers,
        count(distinct email) as count_customer_emails,
        sum(order_adjusted_total) as order_adjusted_total,
        avg(order_adjusted_total) as avg_order_value,
        sum(shipping_cost) as shipping_cost,
        sum(order_adjustment_amount) as order_adjustment_amount,
        sum(order_adjustment_tax_amount) as order_adjustment_tax_amount,
        sum(refund_subtotal) as refund_subtotal,
        sum(refund_total_tax) as refund_total_tax,
        sum(total_discounts) as total_discounts,
        sum(shipping_discount_amount) as shipping_discount_amount,
        sum(percentage_calc_discount_amount) as percentage_calc_discount_amount,
        sum(fixed_amount_discount_amount) as fixed_amount_discount_amount,
        sum(count_discount_codes_applied) as count_discount_codes_applied,
        count(distinct location_id) as count_locations_ordered_from,
        sum(case when count_discount_codes_applied > 0 then 1 else 0 end) as count_orders_with_discounts,
        sum(case when refund_subtotal > 0 then 1 else 0 end) as count_orders_with_refunds,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as last_order_timestamp

    from orders
    group by 1,2

),

order_lines as(

    select *
    from {{ ref('shopify__order_lines') }}
),

order_line_aggregates as (

    select
        order_lines.source_relation,
        cast({{ dbt.date_trunc('day','orders.created_timestamp') }} as date) as date_day,
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.refunded_quantity) as quantity_refunded,
        sum(order_lines.quantity_net_refunds) as quantity_net,
        count(distinct order_lines.variant_id) as count_variants_sold, 
        count(distinct order_lines.product_id) as count_products_sold, 
        sum(case when order_lines.is_gift_card then order_lines.quantity_net_refunds else 0 end) as quantity_gift_cards_sold,
        sum(case when order_lines.is_shipping_required then order_lines.quantity_net_refunds else 0 end) as quantity_requiring_shipping

    from order_lines
    left join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation

    group by 1,2
),

abandoned_checkout as (

    select *
    from {{ var('shopify_abandoned_checkout') }}

    -- "deleted" abandoned checkouts do not appear to have any data tying them to customers,
    -- discounts, or products (and should therefore not get joined in) but let's filter them out here
    where not coalesce(is_deleted, false)
),

abandoned_checkout_aggregates as (

    select
        source_relation,
        cast({{ dbt.date_trunc('day','created_at') }} as date) as date_day,
        count(distinct checkout_id) as count_abandoned_checkouts,
        count(distinct customer_id) as count_customers_abandoned_checkout,
        count(distinct email) as count_customer_emails_abandoned_checkout,
        sum(
            case 
                -- prices are reported in presentment (customer's) currency so let's only take the data where
                -- the presentment currency is the same as the shop's (or maybe we should not have this field...)
                when presentment_currency = shop_currency then total_line_items_price 
            else 0 end) as total_abandoned_checkout_line_items_price

    from abandoned_checkout
    group by 1,2
),

{% if var('shopify_using_fulfillment_event', false) %}

fulfillment_event as (

    select *
    from {{ var('shopify_fulfillment_event') }}
),

fulfillment_aggregates as (

    select 
        source_relation,
        cast({{ dbt.date_trunc('day','happened_at') }} as date) as date_day

        {% for status in ['attempted_delivery', 'delivered', 'failure', 'in_transit', 'out_for_delivery', 'ready_for_pickup', 'label_printed', 'label_purchased', 'confirmed']%}
        , sum(case when lower(status) = '{{ status }}' then 1 else 0 end) as count_fulfillment_{{ status }}
        {% endfor %}
    
    from fulfillment_event
    group by 1,2

),
{% endif %}

final as (

    select 
        shop_calendar.*,

        coalesce(order_aggregates.count_orders, 0) as count_orders,
        coalesce(order_aggregates.count_line_items, 0) as count_line_items,
        coalesce(order_aggregates.count_customers, 0) as count_customers,
        coalesce(order_aggregates.count_customer_emails, 0) as count_customer_emails,
        coalesce(order_aggregates.order_adjusted_total, 0) as order_adjusted_total,
        order_aggregates.avg_order_value,
        coalesce(order_aggregates.shipping_cost, 0) as shipping_cost,
        coalesce(order_aggregates.order_adjustment_amount, 0) as order_adjustment_amount,
        coalesce(order_aggregates.order_adjustment_tax_amount, 0) as order_adjustment_tax_amount,
        coalesce(order_aggregates.refund_subtotal, 0) as refund_subtotal,
        coalesce(order_aggregates.refund_total_tax, 0) as refund_total_tax,
        coalesce(order_aggregates.total_discounts, 0) as total_discounts,
        coalesce(order_aggregates.shipping_discount_amount, 0) as shipping_discount_amount,
        coalesce(order_aggregates.percentage_calc_discount_amount, 0) as percentage_calc_discount_amount,
        coalesce(order_aggregates.fixed_amount_discount_amount, 0) as fixed_amount_discount_amount,
        coalesce(order_aggregates.count_discount_codes_applied, 0) as count_discount_codes_applied,
        coalesce(order_aggregates.count_locations_ordered_from, 0) as count_locations_ordered_from,
        coalesce(order_aggregates.count_orders_with_discounts, 0) as count_orders_with_discounts,
        coalesce(order_aggregates.count_orders_with_refunds, 0) as count_orders_with_refunds,
        order_aggregates.first_order_timestamp,
        order_aggregates.last_order_timestamp,

        coalesce(order_line_aggregates.quantity_sold, 0) as quantity_sold,
        coalesce(order_line_aggregates.quantity_refunded, 0) as quantity_refunded,
        coalesce(order_line_aggregates.quantity_net, 0) as quantity_net,
        coalesce(order_line_aggregates.count_variants_sold, 0) as count_variants_sold,
        coalesce(order_line_aggregates.count_products_sold, 0) as count_products_sold,
        coalesce(order_line_aggregates.quantity_gift_cards_sold, 0) as quantity_gift_cards_sold,
        coalesce(order_line_aggregates.quantity_requiring_shipping, 0) as quantity_requiring_shipping,

        coalesce(abandoned_checkout_aggregates.count_abandoned_checkouts, 0) as count_abandoned_checkouts,
        coalesce(abandoned_checkout_aggregates.count_customers_abandoned_checkout, 0) as count_customers_abandoned_checkout,
        coalesce(abandoned_checkout_aggregates.count_customer_emails_abandoned_checkout, 0) as count_customer_emails_abandoned_checkout,
        coalesce(abandoned_checkout_aggregates.total_abandoned_checkout_line_items_price, 0) as total_abandoned_checkout_line_items_price

        {% if var('shopify_using_fulfillment_event', false) %}
            {% for status in ['attempted_delivery', 'delivered', 'failure', 'in_transit', 'out_for_delivery', 'ready_for_pickup', 'label_printed', 'label_purchased', 'confirmed']%}
        , coalesce(count_fulfillment_{{ status }}, 0) as count_fulfillment_{{ status }}
            {% endfor %}
        {% endif %}

    from shop_calendar
    left join order_aggregates 
        on shop_calendar.source_relation = order_aggregates.source_relation
        and shop_calendar.date_day = order_aggregates.date_day
    left join order_line_aggregates 
        on shop_calendar.source_relation = order_line_aggregates.source_relation
        and shop_calendar.date_day = order_line_aggregates.date_day
    left join abandoned_checkout_aggregates 
        on shop_calendar.source_relation = abandoned_checkout_aggregates.source_relation
        and shop_calendar.date_day = abandoned_checkout_aggregates.date_day
    {% if var('shopify_using_fulfillment_event', false) %}
    left join fulfillment_aggregates 
        on shop_calendar.source_relation = fulfillment_aggregates.source_relation
        and shop_calendar.date_day = fulfillment_aggregates.date_day
    {% endif %}
    
)


select *
from final