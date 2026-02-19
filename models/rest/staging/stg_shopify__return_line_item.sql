{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with base as (

    select *
    from {{ ref('stg_shopify__return_line_item_tmp') }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__return_line_item_tmp')),
                staging_columns=get_return_line_item_columns()
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
        id as return_line_item_id,
        return_id,
        fulfillment_line_item_id,
        quantity,
        refundable_quantity,
        refunded_quantity,
        return_reason,
        return_reason_note,
        restock_type,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields

)

select *
from final
