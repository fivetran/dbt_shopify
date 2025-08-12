{{ config(enabled=(var('shopify_gql_using_abandoned_checkout', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

{{
    shopify.shopify_union_data(
        table_identifier='abandoned_checkout_discount_code', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='gql_abandoned_checkout_discount_code_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}