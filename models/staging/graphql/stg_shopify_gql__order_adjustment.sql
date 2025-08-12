{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

-- this model will be all NULL until you have made an order adjustment in Shopify
with base as (

    select * 
    from {{ ref('stg_shopify_gql__order_adjustment_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__order_adjustment_tmp')),
                staging_columns=get_graphql_order_adjustment_columns()
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
        id as order_adjustment_id,
        refund_id,
        amount_set_pres_amount as amount_pres,
        amount_set_pres_currency_code as amount_pres_currency_code,
        amount_set_shop_amount as amount_shop,
        amount_set_shop_currency_code as amount_shop_currency_code,
        tax_amount_set_pres_amount as tax_amount_pres,
        tax_amount_set_pres_currency_code as tax_amount_pres_currency_code,
        tax_amount_set_shop_amount as tax_amount_shop,
        tax_amount_set_shop_currency_code as tax_amount_shop_currency_code,
        reason,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select * 
from final