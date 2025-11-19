{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select * 
    from {{ ref('stg_shopify__discount_redeem_code_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__discount_redeem_code_tmp')),
                staging_columns=get_discount_redeem_code_columns()
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
        id as discount_code_id,
        async_usage_count,
        code,
        created_by_description,
        created_by_id,
        created_by_title,
        discount_id,
        discount_type,
        source_relation
    from fields
)

select *
from final