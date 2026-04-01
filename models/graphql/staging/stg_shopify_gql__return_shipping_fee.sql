{{ config(enabled=var('shopify_gql_using_return', False) and var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select *
    from {{ ref('stg_shopify_gql__return_shipping_fee_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__return_shipping_fee_tmp')),
                staging_columns=get_graphql_return_shipping_fee_columns()
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
        id as return_shipping_fee_id,
        return_id,
        amount_set_presentment_money_amount as amount_pres_amount,
        amount_set_presentment_money_currency_code as amount_pres_currency_code,
        amount_set_shop_money_amount as amount_shop_amount,
        amount_set_shop_money_currency_code as amount_shop_currency_code,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
