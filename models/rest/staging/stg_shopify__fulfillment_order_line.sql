{{ config(enabled=(var('shopify_using_fulfillment_order_line', true) and var('shopify_api', 'rest') == 'rest')) }}

with base as (

    select * 
    from {{ ref('stg_shopify__fulfillment_order_line_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__fulfillment_order_line_tmp')),
                staging_columns=get_fulfillment_order_line_columns()
            )
        }}

        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}

    from base
),

final as (
    
    select 
        fulfillment_id,
        order_line_id,
        order_id,
        product_id,
        variant_id,
        quantity,
        fulfillable_quantity,
        price,
        name,
        title,
        variant_title,
        sku,
        vendor,
        grams,
        fulfillment_service,
        gift_card,
        requires_shipping,
        taxable,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields
)

select *
from final