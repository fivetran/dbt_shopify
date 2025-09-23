{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__order_line_refund_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__order_line_refund_tmp')),
                staging_columns=get_graphql_order_line_refund_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}
    from base
),

final as (
    
    select 
        id as order_line_refund_id,
        location_id,
        order_line_id,
        subtotal_set_pres_amount as subtotal_pres_amount,
        subtotal_set_pres_currency_code as subtotal_pres_currency_code,
        subtotal_set_shop_amount as subtotal_shop_amount,
        subtotal_set_shop_currency_code as subtotal_shop_currency_code,
        total_tax_set_pres_amount as total_tax_pres_amount,
        total_tax_set_pres_currency_code as total_tax_pres_currency_code,
        total_tax_set_shop_amount as total_tax_shop_amount,
        total_tax_set_shop_currency_code as total_tax_shop_currency_code,
        quantity,
        refund_id,
        lower(restock_type) as restock_type,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

        {{ fivetran_utils.fill_pass_through_columns('order_line_refund_pass_through_columns') }}

    from fields
)

select *
from final
