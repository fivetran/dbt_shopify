{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__refund_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__refund_tmp')),
                staging_columns=get_graphql_refund_columns()
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
        id as refund_id,
        note,
        order_id,
        staff_member_id as user_id,
        return_id,
        total_refunded_set_pres_amount as total_refunded_pres_amount,
        total_refunded_set_pres_currency_code as total_refunded_pres_currency_code,
        total_refunded_set_shop_amount as total_refunded_shop_amount,
        total_refunded_set_shop_currency_code as total_refunded_shop_currency_code,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
