{{ config(enabled=(var('shopify_using_product_variant_media', False) and var('shopify_api', 'rest') == 'rest')) }}

{{
    shopify.shopify_union_data(
        table_identifier='product_variant_media', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='product_variant_media_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases'
    )
}}