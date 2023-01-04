with products as (

    select *
    from {{ var('shopify_product') }}
), 

order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}
), 

orders as (

    select *
    from {{ ref('shopify__orders')}}
), 

collection_product as (

    select *
    from {{ var('shopify_collection_product') }}
),

collection as (

    select *
    from {{ var('shopify_collection') }}

    -- limit to only active collections
    where not coalesce(is_deleted, false)
),

product_tag as (

    select *
    from {{ var('shopify_product_tag') }}
),

product_variant as (

    select *
    from {{ var('shopify_product_variant') }}
),

product_image as (

    select *
    from {{ var('shopify_product_image') }}
),

order_lines_aggregated as (

    select 
        order_lines.product_id, 
        order_lines.source_relation,
        sum(order_lines.quantity) as quantity_sold,
        sum(order_lines.pre_tax_price) as subtotal_sold,

        {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
        sum(order_lines.quantity_net_refunds) as quantity_sold_net_refunds,
        sum(order_lines.subtotal_net_refunds) as subtotal_sold_net_refunds,
        {% endif %}

        min(orders.created_timestamp) as first_order_timestamp,
        max(orders.created_timestamp) as most_recent_order_timestamp
    from order_lines
    left join orders
        using (order_id, source_relation)
    group by 1,2

), 

collections_aggregated as (

    select
        collection_product.product_id,
        collection_product.source_relation,
        {{ fivetran_utils.string_agg(field_to_agg='collection.title', delimiter="', '") }} as collections
    from collection_product 
    join collection 
        on collection_product.collection_id = collection.collection_id
        and collection_product.source_relation = collection.source_relation
    group by 1,2
),

tags_aggregated as (

    select 
        product_id,
        source_relation,
        {{ fivetran_utils.string_agg(field_to_agg='value', delimiter="', '") }} as tags
    
    from product_tag
    group by 1,2
),

variants_aggregated as (

    select 
        product_id,
        source_relation,
        count(variant_id) as count_variants

    from product_variant
    group by 1,2

),

images_aggregated as (

    select 
        product_id,
        source_relation,
        count(*) as count_images
    from product_image
    group by 1,2
),

joined as (

    select
        products.*,
        coalesce(order_lines_aggregated.quantity_sold,0) as quantity_sold,
        coalesce(order_lines_aggregated.subtotal_sold,0) as subtotal_sold,

        {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
        coalesce(order_lines_aggregated.quantity_sold_net_refunds,0) as quantity_sold_net_refunds,
        coalesce(order_lines_aggregated.subtotal_sold_net_refunds,0) as subtotal_sold_net_refunds,
        {% endif %}
        
        order_lines_aggregated.first_order_timestamp,
        order_lines_aggregated.most_recent_order_timestamp,

        collections_aggregated.collections,
        tags_aggregated.tags,
        variants_aggregated.count_variants,
        coalesce(images_aggregated.count_images, 0) > 0 as has_product_image

    from products
    left join order_lines_aggregated
        on products.product_id = order_lines_aggregated.product_id
        and products.source_relation = order_lines_aggregated.source_relation
    left join collections_aggregated
        on products.product_id = collections_aggregated.product_id
        and products.source_relation = collections_aggregated.source_relation
    left join tags_aggregated
        on products.product_id = tags_aggregated.product_id
        and products.source_relation = tags_aggregated.source_relation
    left join variants_aggregated
        on products.product_id = variants_aggregated.product_id
        and products.source_relation = variants_aggregated.source_relation
    left join images_aggregated
        on products.product_id = images_aggregated.product_id
        and products.source_relation = images_aggregated.source_relation
)

select *
from joined