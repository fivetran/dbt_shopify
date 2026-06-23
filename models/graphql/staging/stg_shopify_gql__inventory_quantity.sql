{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__inventory_quantity_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__inventory_quantity_tmp')),
                staging_columns=get_graphql_inventory_quantity_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}
    from base
),

final as (
    
    select 
        id as inventory_quantity_id,
        inventory_item_id,
        inventory_level_id,
        name as inventory_state_name,
        quantity,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'inventory_item_id', 'inventory_level_id', 'name', 'source_relation']) }} as unique_key

    from fields
)

select *
from final