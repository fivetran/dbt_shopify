{{ config(enabled=var('shopify_api', 'rest') == 'rest' and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_collection_metafields', True)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify__collection", 
    reference_values = ['collection'],
    id_column = "collection_id"
) }}