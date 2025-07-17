{{ config(enabled=var('shopify_api', 'rest') == 'rest' and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify__product", 
    reference_values = ['product'],
    id_column = "product_id"
) }}