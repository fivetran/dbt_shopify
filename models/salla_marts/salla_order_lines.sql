with order_items as (

    select *
    from {{ ref('stg_salla__order_item') }}

), orders as (

    select
        order_id,
        source_relation,
        customer_id,
        order_date,
        created_timestamp,
        status,
        payment_method
    from {{ ref('stg_salla__order') }}

), products as (

    select
        product_id,
        source_relation,
        product_name as product_title,
        product_type,
        brand_id,
        category_id,
        status as product_status
    from {{ ref('stg_salla__product') }}

), product_variants as (

    select
        variant_id,
        product_id,
        source_relation,
        sku as variant_sku,
        price as variant_price
    from {{ ref('stg_salla__product_variant') }}

), joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        order_items.variant_id,
        order_items.source_relation,

        -- order info
        orders.customer_id,
        orders.order_date,
        orders.created_timestamp as order_created_timestamp,
        orders.status as order_status,
        orders.payment_method,

        -- line item info
        order_items.product_name,
        order_items.product_sku,
        order_items.product_options,
        order_items.quantity,
        order_items.unit_price,
        order_items.total_price,

        -- product info
        products.product_title,
        products.product_type,
        products.brand_id,
        products.category_id,
        products.product_status,

        -- variant info
        product_variants.variant_sku,
        product_variants.variant_price

    from order_items
    left join orders
        on order_items.order_id = orders.order_id
        and order_items.source_relation = orders.source_relation
    left join products
        on order_items.product_id = products.product_id
        and order_items.source_relation = products.source_relation
    left join product_variants
        on order_items.variant_id = product_variants.variant_id
        and order_items.source_relation = product_variants.source_relation

)

select *
from joined
