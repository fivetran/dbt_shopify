{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{{
    shopify.shopify_union_data(
        table_identifier='order_shipping_tax_line', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_order_shipping_tax_line_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}
