{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select * 
    from {{ ref('stg_shopify__inventory_item_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__inventory_item_tmp')),
                staging_columns=get_inventory_item_columns()
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
        id as inventory_item_id,
        sku,
        _fivetran_deleted as is_deleted, -- won't filter out for now
        coalesce(unit_cost_amount, cost) as unit_cost_amount,
        unit_cost_currency_code,
        country_code_of_origin,
        province_code_of_origin,
        requires_shipping as is_shipping_required,
        tracked as is_inventory_quantity_tracked,
        duplicate_sku_count,
        harmonized_system_code,
        inventory_history_url,
        legacy_resource_id,
        measurement_id,
        measurement_weight_value,
        measurement_weight_unit,
        tracked_editable_locked as is_tracked_editable_locked,
        tracked_editable_reason,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields
)

select *
from final
