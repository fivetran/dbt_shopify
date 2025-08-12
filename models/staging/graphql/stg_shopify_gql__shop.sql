{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__shop_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__shop_tmp')),
                staging_columns=get_graphql_shop_columns()
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
        id as shop_id,
        name,
        _fivetran_deleted as is_deleted,
        billing_address_address_1 as address_1,
        billing_address_address_2 as address_2,
        billing_address_city as city,
        billing_address_province as province,
        billing_address_province_code as province_code,
        billing_address_country_code_v_2 as country, -- in REST API country = code
        billing_address_country_code_v_2 as country_code,
        billing_address_country as country_name,
        billing_address_zip as zip,
        billing_address_latitude as latitude,
        billing_address_longitude as longitude,
        currency_code as currency,
        {{ shopify.json_to_string("enabled_presentment_currencies", source_columns_in_relation) }} as enabled_presentment_currencies,
        contact_email as customer_email,
        email,
        primary_domain_host as domain,
        billing_address_phone as phone,
        timezone_abbreviation,
        {# timezone_offset is formatted like -0400 instead of -04:00 #}
        timezone_offset, 
        timezone_offset_minutes, 
        iana_timezone, 
        primary_domain_localization_default_locale as primary_locale,
        weight_unit,
        myshopify_domain,
        shop_owner_name as shop_owner,
        tax_shipping as has_shipping_taxes,
        coalesce(taxes_included, false) as has_taxes_included_in_price,
        features_storefront as has_storefront,
        checkout_api_supported as has_checkout_api_supported,
        currency_formats_money_format as money_format,
        currency_formats_money_in_emails_format as money_in_emails_format,
        currency_formats_money_with_currency_format as money_with_currency_format,
        currency_formats_money_with_currency_in_emails_format as money_with_currency_in_emails_format,
        plan_display_name,
        password_enabled as is_password_enabled,
        setup_required as is_setup_required,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
