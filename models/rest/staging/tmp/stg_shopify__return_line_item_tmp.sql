{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}
-- this model will be all NULL until you create a return in Shopify

{{
    shopify.shopify_union_data(
        table_identifier='return_line_item',
        database_variable='shopify_database',
        schema_variable='shopify_schema',
        default_database=target.database,
        default_schema='shopify',
        default_variable='return_line_item_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases'
    )
}}
