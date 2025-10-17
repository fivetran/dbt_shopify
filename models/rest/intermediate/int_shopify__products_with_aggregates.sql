{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

{% set product_metafields_enabled = var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_product_metafields', True)) %}

with products as (

    select *
    from {{ ref('shopify__product_metafields') if product_metafields_enabled else ref('stg_shopify__product') }}
), 

collection_product as (

    select *
    from {{ ref('stg_shopify__collection_product') }}
),

collection as (

    select *
    from {{ ref('stg_shopify__collection') }}
    where not coalesce(is_deleted, false) -- limit to only active collections
),

product_tag as (

    select *
    from {{ ref('stg_shopify__product_tag') }}
),

product_variant as (

    select *
    from {{ ref('stg_shopify__product_variant') }}
), 

product_media as (

    select *
    from {{ ref('stg_shopify__product_media') }}
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

media_aggregated as (

    select 
        product_id,
        source_relation,
        count(distinct media_id) as count_media
    from product_media
    group by 1,2
), 

joined as (

    select
        products.*,
        collections_aggregated.collections,
        tags_aggregated.tags,
        variants_aggregated.count_variants,
        coalesce(media_aggregated.count_media, 0) > 0 as has_product_media

    from products
    left join collections_aggregated
        on products.product_id = collections_aggregated.product_id
        and products.source_relation = collections_aggregated.source_relation
    left join tags_aggregated
        on products.product_id = tags_aggregated.product_id
        and products.source_relation = tags_aggregated.source_relation
    left join variants_aggregated
        on products.product_id = variants_aggregated.product_id
        and products.source_relation = variants_aggregated.source_relation
    left join media_aggregated
        on products.product_id = media_aggregated.product_id
        and products.source_relation = media_aggregated.source_relation
)

select *
from joined