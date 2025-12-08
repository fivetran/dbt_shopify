{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{{
    shopify.shopify_union_data(
        table_identifier='order_custom_attribute' if var('shopify_gql_using_order_custom_attribute', shopify.does_table_exist('order_custom_attribute', 'shopify_graphql')) else 'order_note_attribute', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_order_custom_attribute_source' if var('shopify_gql_using_refund_line_item', shopify.does_table_exist('order_custom_attribute', 'shopify_graphql')) else 'gql_order_note_attribute_source', 
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}