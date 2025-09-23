{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__discount_allocation_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__discount_allocation_tmp')),
                staging_columns=get_graphql_discount_allocation_columns()
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
        allocated_amount_set_pres_amount as allocated_pres_amount,
        allocated_amount_set_pres_currency_code as allocated_pres_currency_code,
        allocated_amount_set_shop_amount as allocated_shop_amount,
        allocated_amount_set_shop_currency_code as allocated_shop_currency_code,
        discount_application_index,
        index,
        order_line_id,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['order_line_id', 'discount_application_index', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
