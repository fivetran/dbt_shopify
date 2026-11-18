{{ config(enabled=(var('shopify_gql_using_fulfillment_line_item', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__fulfillment_line_item_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__fulfillment_line_item_tmp')),
                staging_columns=get_graphql_fulfillment_line_item_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}
    from base
),

final as (
    
    select 
        id as fulfillment_line_item_id,
        fulfillment_id,
        order_line_id,
        product_id,
        product_variant_id,
        quantity,
        discounted_total_set_pres_amount as discounted_total_pres_amount,
        discounted_total_set_pres_currency_code as discounted_total_pres_currency_code,
        discounted_total_set_shop_amount as discounted_total_shop_amount,
        discounted_total_set_shop_currency_code as discounted_total_shop_currency_code,
        original_total_set_pres_amount as original_total_pres_amount,
        original_total_set_pres_currency_code as original_total_pres_currency_code,
        original_total_set_shop_amount as original_total_shop_amount,
        original_total_set_shop_currency_code as original_total_shop_currency_code,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final