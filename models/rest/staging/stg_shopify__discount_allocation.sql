{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select * 
    from {{ ref('stg_shopify__discount_allocation_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__discount_allocation_tmp')),
                staging_columns=get_discount_allocation_columns()
            )
        }}

        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}

    from base
),

final as (
    
    select 
        amount,
        amount_set_presentment_money_amount,
        amount_set_presentment_money_currency_code,
        amount_set_shop_money_amount,
        amount_set_shop_money_currency_code,
        discount_application_index,
        index,
        order_line_id,        
        source_relation
        
    from fields
)

select *
from final