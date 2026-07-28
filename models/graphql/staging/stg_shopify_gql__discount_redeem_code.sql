{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__discount_redeem_code_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__discount_redeem_code_tmp')),
                staging_columns=get_graphql_discount_redeem_code_columns()
            )
        }}

        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}

    from base
),

final as (

    select
        id as discount_code_id,
        async_usage_count,
        code,
        created_by_description, -- deprecated as of August 2026. Will be removed in a future release.
        created_by_id,
        created_by_title, -- deprecated as of August 2026. Will be removed in a future release.
        discount_id,
        discount_type,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final