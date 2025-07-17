{{ config(enabled=var('shopify_api', 'rest') == 'rest' and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_variant_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify__product_variant",
    reference_values = ['variant', 'productvariant'],
    id_column = "variant_id"
) }}