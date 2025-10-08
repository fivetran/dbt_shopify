{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql') and var('shopify_gql_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_order_metafields', True)) ) }}

{{ shopify.get_metafields( 
    source_object = "int_shopify_gql__order", 
    reference_values = ['order'],
    id_column = "order_id",
    lookup_object="stg_shopify_gql__metafield"
) }}

{# Does not contain total_line_items_price columns as these are calculated in shopify_gql_orders__order_line_aggregates in GraphQL #}