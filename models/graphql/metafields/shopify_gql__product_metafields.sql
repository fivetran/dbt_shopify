{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify_gql__product", 
    reference_values = ['product'],
    id_column = "product_id",
    lookup_object="stg_shopify_gql__metafield"
) }}