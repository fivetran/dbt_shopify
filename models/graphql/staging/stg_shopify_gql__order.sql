{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__order_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__order_tmp')),
                staging_columns=get_graphql_order_columns()
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
        id as order_id,
        staff_member_id as user_id,
        total_discounts_set_pres_amount as total_discounts_pres_amount,
        total_discounts_set_pres_currency_code as total_discounts_pres_currency_code,
        total_discounts_set_shop_amount as total_discounts_shop_amount,
        total_discounts_set_shop_currency_code as total_discounts_shop_currency_code,
        total_price_set_pres_amount as total_price_pres_amount,
        total_price_set_pres_currency_code as total_price_pres_currency_code,
        total_price_set_shop_amount as total_price_shop_amount,
        total_price_set_shop_currency_code as total_price_shop_currency_code,
        total_tax_set_pres_amount as total_tax_pres_amount,
        total_tax_set_pres_currency_code as total_tax_pres_currency_code,
        total_tax_set_shop_amount as total_tax_shop_amount,
        total_tax_set_shop_currency_code as total_tax_shop_currency_code,
        source_name,
        subtotal_price_set_pres_amount as subtotal_price_pres_amount,
        subtotal_price_set_pres_currency_code as subtotal_price_pres_currency_code,
        subtotal_price_set_shop_amount as subtotal_price_shop_amount,
        subtotal_price_set_shop_currency_code as subtotal_price_shop_currency_code,
        taxes_included as has_taxes_included,
        total_weight,
        total_tip_received_set_pres_amount as total_tip_received_pres_amount,
        total_tip_received_set_pres_currency_code as total_tip_received_pres_currency_code,
        total_tip_received_set_shop_amount as total_tip_received_shop_amount,
        total_tip_received_set_shop_currency_code as total_tip_received_shop_currency_code,
        location_id,
        name,
        note,
        number, -- Will be included in 2025-07 release of GraphQL API
        cancel_reason,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(cancelled_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as cancelled_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(closed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as closed_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(processed_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as processed_timestamp,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_timestamp,
        currency_code as currency,
        customer_id,
        lower(email) as email,
        lower(display_financial_status) as financial_status,
        lower(display_fulfillment_status) as fulfillment_status,
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
        client_ip as browser_ip,
        total_shipping_price_set_pres_amount as shipping_cost_pres_amount,
        total_shipping_price_set_pres_currency_code as shipping_cost_pres_currency_code,
        total_shipping_price_set_shop_amount as shipping_cost_shop_amount,
        total_shipping_price_set_shop_currency_code as shipping_cost_shop_currency_code,
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
        app_id,
        customer_locale,
        status_page_url as order_status_url,
        presentment_currency_code as presentment_currency,
        test as is_test_order,
        _fivetran_deleted as is_deleted,
        customer_accepts_marketing as has_buyer_accepted_marketing,
        confirmed as is_confirmed,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

        {{ fivetran_utils.fill_pass_through_columns('order_pass_through_columns') }}

    from fields
)

select *
from final
where not coalesce(is_test_order, false)
and not coalesce(is_deleted, false)