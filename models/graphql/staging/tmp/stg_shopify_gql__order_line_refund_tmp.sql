{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{{
    shopify.shopify_union_data(
        table_identifier='refund_line_item' if var('shopify_gql__using_refund_line_item', shopify.does_table_exist('refund_line_item', 'shopify_graphql')) else 'order_line_refund', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_order_line_refund_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}
