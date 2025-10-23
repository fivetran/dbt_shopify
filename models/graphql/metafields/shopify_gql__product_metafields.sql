{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_gql_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_product_metafields', True)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify_gql__product", 
    reference_values = ['product'],
    id_column = "product_id",
    lookup_object="stg_shopify_gql__metafield"
) }}