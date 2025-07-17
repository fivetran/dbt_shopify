{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_using_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_order_metafields', False)) ) }}

{{ shopify.get_metafields( 
    source_object = "stg_shopify_gql__order", 
    reference_values = ['order'],
    id_column = "order_id",
    lookup_object="stg_shopify_gql__metafield"
) }}