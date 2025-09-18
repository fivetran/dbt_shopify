{{ config(enabled=(var('shopify_gql_using_abandoned_checkout', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__abandoned_checkout_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__abandoned_checkout_tmp')),
                staging_columns=get_graphql_abandoned_checkout_columns()
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
        _fivetran_deleted as is_deleted,
        abandoned_checkout_url,
        billing_address_address_1,
        billing_address_address_2,
        billing_address_city,
        billing_address_company,
        billing_address_country,
        billing_address_country_code,
        billing_address_first_name,
        billing_address_last_name,
        billing_address_latitude,
        billing_address_longitude,
        billing_address_name,
        billing_address_phone,
        billing_address_province,
        billing_address_province_code,
        billing_address_zip,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        customer_id,
        id as checkout_id,
        name,
        note,
        shipping_address_address_1,
        shipping_address_address_2,
        shipping_address_city,
        shipping_address_company,
        shipping_address_country,
        shipping_address_country_code,
        shipping_address_first_name,
        shipping_address_last_name,
        shipping_address_latitude,
        shipping_address_longitude,
        shipping_address_name,
        shipping_address_phone,
        shipping_address_province,
        shipping_address_province_code,
        shipping_address_zip,
        subtotal_price_set_shop_amount as subtotal_price_shop_amount,
        subtotal_price_set_shop_currency_code as subtotal_price_shop_currency_code,
        subtotal_price_set_pres_amount as subtotal_price_pres_amount,
        subtotal_price_set_pres_currency_code as subtotal_price_pres_currency_code,
        taxes_included as has_taxes_included,
        total_discount_set_shop_amount as total_discount_shop_amount,
        total_discount_set_shop_currency_code as total_discount_shop_currency_code,
        total_discount_set_pres_amount as total_discount_pres_amount,
        total_discount_set_pres_currency_code as total_discount_pres_currency_code,
        total_duties_set_shop_amount as total_duties_shop_amount,
        total_duties_set_shop_currency_code as total_duties_shop_currency_code,
        total_duties_set_pres_amount as total_duties_pres_amount,
        total_duties_set_pres_currency_code as total_duties_pres_currency_code,
        total_line_items_price_set_shop_amount as total_line_items_price_shop_amount,
        total_line_items_price_set_shop_currency_code as total_line_items_price_shop_currency_code,
        total_line_items_price_set_pres_amount as total_line_items_price_pres_amount,
        total_line_items_price_set_pres_currency_code as total_line_items_price_pres_currency_code,
        total_price_set_shop_amount as total_price_shop_amount,
        total_price_set_shop_currency_code as total_price_shop_currency_code,
        total_price_set_pres_amount as total_price_pres_amount,
        total_price_set_pres_currency_code as total_price_pres_currency_code,
        total_tax_set_shop_amount as total_tax_shop_amount,
        total_tax_set_shop_currency_code as total_tax_shop_currency_code,
        total_tax_set_pres_amount as total_tax_pres_amount,
        total_tax_set_pres_currency_code as total_tax_pres_currency_code,
        {{ shopify.fivetran_convert_timezone(column='cast(completed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as completed_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key
        
    from fields
)

select *
from final
