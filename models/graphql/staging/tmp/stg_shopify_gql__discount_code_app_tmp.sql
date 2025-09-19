{{ config(enabled=(var('shopify_gql_using_discount_code_app', False) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

{{
    shopify.shopify_union_data(
        table_identifier='discount_code_app', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_discount_code_app_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}