{{ config(enabled=var('shopify_api', 'rest') == 'rest' and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_shop_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify__shop", 
    reference_values = ['shop'],
    id_column = "shop_id"
) }}