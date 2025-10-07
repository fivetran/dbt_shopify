with products as (

    select * from {{ ref('stg_shopify__product') }}

), product_variants as (

    select
        product_id,
        count(*) as count_variants
    from {{ source('shopify_raw', 'product_variants') }}
    group by 1

), product_order_lines as (

    select *
    from {{ ref('int_shopify__product__order_line_aggregates')}}

), product_tags_source as (

    select
        product_id,
        source_relation,
        tags
    from {{ ref('stg_shopify__product') }}
    where tags is not null

), product_tags as (

    select
        product_id,
        source_relation,
        string_agg(distinct trim(tag), ', ') as tags

    from product_tags_source,
    unnest(split(tags, ',')) as tag
    group by 1, 2

), joined as (

    select
        products.* except(tags),
        product_tags.tags as product_tags,
        coalesce(product_variants.count_variants, 0) as count_variants,
        coalesce(product_order_lines.quantity_sold,0) as total_quantity_sold,
        coalesce(product_order_lines.subtotal_sold,0) as subtotal_sold,
        coalesce(product_order_lines.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        coalesce(product_order_lines.subtotal_sold_net_refunds,0) as subtotal_sold_net_refunds,
        product_order_lines.first_order_timestamp,
        product_order_lines.most_recent_order_timestamp,
        product_order_lines.avg_quantity_per_order_line as avg_quantity_per_order_line,
        coalesce(product_order_lines.product_total_discount,0) as product_total_discount,
        product_order_lines.product_avg_discount_per_order_line as product_avg_discount_per_order_line,
        coalesce(product_order_lines.product_total_tax,0) as product_total_tax,
        product_order_lines.product_avg_tax_per_order_line as product_avg_tax_per_order_line

    from products
    left join product_variants
        on products.product_id = product_variants.product_id
    left join product_order_lines
        on products.product_id = product_order_lines.product_id
        and products.source_relation = product_order_lines.source_relation
    left join product_tags
        on products.product_id = product_tags.product_id
        and products.source_relation = product_tags.source_relation
)

select *
from joined
