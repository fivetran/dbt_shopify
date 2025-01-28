{{ config(enabled=var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_image_metafields', False)) ) }}

{{ shopify.get_metafields(
    source_object = "stg_shopify__product_image",
    id_column_override = 'product_image_id', 
    reference_values = ['image', 'productimage']
) }}
