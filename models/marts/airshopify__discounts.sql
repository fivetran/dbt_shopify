with discount_codes as (

    select * from {{ ref('stg_shopify__discount_code') }}

), order_discount_codes as (

    select * from {{ ref('stg_shopify__order_discount_code') }}

), orders as (

    select * from {{ ref('airshopify__orders') }}

), order_aggregates as (

    select
        order_discount_codes.code,
        order_discount_codes.source_relation,
        count(distinct orders.order_id) as count_orders,
        avg(order_discount_codes.amount) as avg_order_discount_amount,
        sum(order_discount_codes.amount) as total_order_discount_amount,
        sum(orders.total_line_items_price) as total_order_line_items_price,
        sum(orders.shipping_cost) as total_order_shipping_cost,
        sum(orders.refund_subtotal) as total_order_refund_amount,
        count(distinct orders.customer_id) as count_customers,
        count(distinct orders.email) as count_customer_emails

    from order_discount_codes
    left join orders
        on order_discount_codes.order_id = orders.order_id
        and order_discount_codes.source_relation = orders.source_relation
    group by 1, 2

), abandoned_checkout_aggregates as (

    select
        json_extract_scalar(discount_code, '$.code') as code,
        'airbyte' as source_relation,
        sum(cast(json_extract_scalar(discount_code, '$.amount') as numeric)) as total_abandoned_checkout_discount_amount,
        sum(total_price) as total_abandoned_checkout_shipping_price,
        count(distinct id) as count_abandoned_checkouts,
        count(distinct cast(json_extract_scalar(customer, '$.id') as int64)) as count_abandoned_checkout_customers,
        count(distinct email) as count_abandoned_checkout_customer_emails

    from {{ source('shopify_raw', 'abandoned_checkouts') }},
    unnest(json_extract_array(discount_codes)) as discount_code
    where discount_codes is not null
    group by 1, 2

), joined as (

    select
        discount_codes.code,
        discount_codes.discount_code_id,
        discount_codes.discount_type,
        discount_codes.applies_once_per_customer,
        discount_codes.usage_count,
        cast(null as int64) as codes_count, -- not available in new schema
        cast(null as string) as codes_precision, -- not available in new schema
        cast(null as bool) as combines_with_order_discounts, -- not available
        cast(null as bool) as combines_with_product_discounts, -- not available
        cast(null as bool) as combines_with_shipping_discounts, -- not available
        discount_codes.created_at,
        cast(null as bool) as customer_selection_all_customers, -- not available
        discount_codes.ends_at,
        discount_codes.starts_at,
        discount_codes.status,
        discount_codes.title,
        discount_codes.total_sales_amount,
        discount_codes.total_sales_currency_code,
        discount_codes.updated_at,
        discount_codes.usage_limit,
        discount_codes.source_relation,
        cast(null as string) as allocation_method, -- not available
        cast(null as string) as description, -- not available
        cast(null as string) as target_selection, -- not available
        cast(null as string) as target_type, -- not available
        cast(null as string) as application_type, -- not available
        cast(null as numeric) as value, -- not available
        cast(null as string) as value_type, -- not available
        {{ dbt_utils.generate_surrogate_key(['discount_codes.code', 'discount_codes.source_relation']) }} as discounts_unique_key,

        -- order aggregates
        coalesce(order_aggregates.count_orders, 0) as count_orders,
        order_aggregates.avg_order_discount_amount,
        coalesce(order_aggregates.total_order_discount_amount, 0) as total_order_discount_amount,
        coalesce(order_aggregates.total_order_line_items_price, 0) as total_order_line_items_price,
        coalesce(order_aggregates.total_order_shipping_cost, 0) as total_order_shipping_cost,
        coalesce(order_aggregates.total_order_refund_amount, 0) as total_order_refund_amount,
        coalesce(order_aggregates.count_customers, 0) as count_customers,
        coalesce(order_aggregates.count_customer_emails, 0) as count_customer_emails,

        -- abandoned checkout aggregates
        coalesce(abandoned_checkout_aggregates.total_abandoned_checkout_discount_amount, 0) as total_abandoned_checkout_discount_amount,
        coalesce(abandoned_checkout_aggregates.total_abandoned_checkout_shipping_price, 0) as total_abandoned_checkout_shipping_price,
        coalesce(abandoned_checkout_aggregates.count_abandoned_checkouts, 0) as count_abandoned_checkouts,
        coalesce(abandoned_checkout_aggregates.count_abandoned_checkout_customers, 0) as count_abandoned_checkout_customers,
        coalesce(abandoned_checkout_aggregates.count_abandoned_checkout_customer_emails, 0) as count_abandoned_checkout_customer_emails

    from discount_codes
    left join order_aggregates
        on discount_codes.code = order_aggregates.code
        and discount_codes.source_relation = order_aggregates.source_relation
    left join abandoned_checkout_aggregates
        on discount_codes.code = abandoned_checkout_aggregates.code
        and discount_codes.source_relation = abandoned_checkout_aggregates.source_relation

)

select *
from joined
