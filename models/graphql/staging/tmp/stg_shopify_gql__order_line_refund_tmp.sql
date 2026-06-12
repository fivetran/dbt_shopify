{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{% if var('shopify_union_schemas', []) | length > 0 or var('shopify_union_databases', []) | length > 0 %}

{{
    shopify.shopify_union_data(
        table_identifier='refund_line_item' if var('shopify_gql_using_refund_line_item', shopify.does_table_exist('refund_line_item', 'shopify_graphql')) else 'order_line_refund'
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases',
        shopify_model_api='graphql'
    )
}}

{% else %}

{{
    fivetran_utils.union_connections(
        connection_dictionary='shopify_sources',
        single_source_name='shopify_graphql',
        single_table_name='refund_line_item'
    )
}}

{% endif %}