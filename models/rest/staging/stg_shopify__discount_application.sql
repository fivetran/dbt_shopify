{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select * 
    from {{ ref('stg_shopify__discount_application_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__discount_application_tmp')),
                staging_columns=get_discount_application_columns()
            )
        }}

        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}

    from base
),

final as (
    
    select 
        allocation_method,
        upper(code) as code,
        description,
        index,
        order_id,
        target_selection,
        target_type,
        title,
        type,
        value,
        value_type,
        source_relation
    from fields
)

select *
from final