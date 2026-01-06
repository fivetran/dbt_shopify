{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{{
    shopify.shopify_union_data(
        table_identifier='order_line_tax_line' if var('shopify_gql_using_order_line_tax_line', shopify.does_table_exist('order_line_tax_line', 'shopify_graphql')) else 'tax_line', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_order_line_tax_line_source' if var('shopify_gql_using_order_line_tax_line', shopify.does_table_exist('order_line_tax_line', 'shopify_graphql')) else 'gql_tax_line_source', 
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}
