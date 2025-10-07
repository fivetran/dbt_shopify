{{ config(enabled=var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_collection_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify__collection", 
    reference_values = ['collection'],
    id_column = "collection_id"
) }}