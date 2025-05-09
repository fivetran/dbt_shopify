{{ config(enabled=var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_image_metafields', False)) ) }}

{{ shopify.get_metafields(
    source_object = "stg_shopify__product_image",
    reference_values = ['image', 'productimage', 'mediaimage'],
    id_column = "product_image_id"
) }}
