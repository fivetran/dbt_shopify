{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_using_gql_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_product_variant_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "int_shopify_gql__product_variant",
    reference_values = ['variant', 'productvariant'],
    id_column = "variant_id",
    lookup_object="stg_shopify_gql__metafield"
) }}