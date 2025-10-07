with products as (

    select * from {{ ref('stg_salla__product') }}

), product_variants as (

    select
        product_id,
        source_relation,
        count(*) as count_variants
    from {{ ref('stg_salla__product_variant') }}
    group by 1, 2

), order_items as (

    select
        product_id,
        source_relation,
        sum(quantity) as total_quantity_sold,
        sum(total_price) as subtotal_sold,
        count(distinct order_id) as count_orders,
        min(created_timestamp) as first_order_timestamp,
        max(created_timestamp) as most_recent_order_timestamp,
        avg(quantity) as avg_quantity_per_order_line
    from {{ ref('stg_salla__order_item') }}
    group by 1, 2

), brands as (

    select
        brand_id,
        source_relation,
        brand_name
    from {{ ref('stg_salla__brand') }}

), categories as (

    select
        category_id,
        source_relation,
        category_name
    from {{ ref('stg_salla__category') }}

), joined as (

    select
        products.*,
        brands.brand_name,
        categories.category_name,
        coalesce(product_variants.count_variants, 0) as count_variants,
        coalesce(order_items.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(order_items.subtotal_sold, 0) as subtotal_sold,
        coalesce(order_items.count_orders, 0) as count_orders,
        order_items.first_order_timestamp,
        order_items.most_recent_order_timestamp,
        order_items.avg_quantity_per_order_line

    from products
    left join product_variants
        on products.product_id = product_variants.product_id
        and products.source_relation = product_variants.source_relation
    left join order_items
        on products.product_id = order_items.product_id
        and products.source_relation = order_items.source_relation
    left join brands
        on products.brand_id = brands.brand_id
        and products.source_relation = brands.source_relation
    left join categories
        on products.category_id = categories.category_id
        and products.source_relation = categories.source_relation
)

select *
from joined
