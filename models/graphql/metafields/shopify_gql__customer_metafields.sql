{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_using_gql_metafield', True) and (var('shopify_using_all_metafields', False) or var('shopify_using_customer_metafields', False)) )}}

{{ shopify.get_metafields( 
    source_object = "int_shopify_gql__customer", 
    reference_values = ['customer'],
    id_column = "customer_id",
    lookup_object="stg_shopify_gql__metafield"
) }}