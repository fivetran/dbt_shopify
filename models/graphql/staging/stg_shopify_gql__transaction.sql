{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{% set source_columns_in_relation = adapter.get_columns_in_relation(ref('stg_shopify_gql__transaction_tmp')) %}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__transaction_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__transaction_tmp')),
                staging_columns=get_graphql_transaction_columns()
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
        id as transaction_id,
        order_id,
        refund_id,
        amount_set_pres_amount as amount_pres,
        amount_set_shop_amount as amount_shop,
        device_id, -- Will be included in 2025-07 release of GraphQL API
        gateway,
        amount_set_pres_currency_code as amount_pres_currency_code,
        amount_set_shop_currency_code as amount_shop_currency_code,
        parent_id,
        payment_avs_result_code,
        payment_credit_card_bin,
        payment_cvv_result_code,
        payment_credit_card_number,
        payment_credit_card_company,
        lower(kind) as kind, -- lower in REST api
        {{ shopify.json_to_string("receipt_json", source_columns_in_relation) }} as receipt,
        currency_exchange_id, -- Will be included in 2025-07 release of GraphQL API
        currency_exchange_adjustment, -- Will be included in 2025-07 release of GraphQL API
        currency_exchange_original_amount, -- Will be included in 2025-07 release of GraphQL API
        currency_exchange_final_amount, -- Will be included in 2025-07 release of GraphQL API
        currency_exchange_currency, -- Will be included in 2025-07 release of GraphQL API
        error_code,
        lower(status) as status, -- lower in REST api
        staff_member_id as user_id,
        authorization_code,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(processed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as processed_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(authorization_expires_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as authorization_expires_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

        {{ fivetran_utils.fill_pass_through_columns('transaction_pass_through_columns') }}

    from fields
    where not coalesce(test, false)
)

select *
from final