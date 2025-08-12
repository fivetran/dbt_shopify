{{ config(enabled=(var('shopify_gql_using_fulfillment_order_line_item', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__fulfillment_order_line_item_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__fulfillment_order_line_item_tmp')),
                staging_columns=get_graphql_fulfillment_order_line_item_columns()
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
        id as fulfillment_order_line_item_id,
        fulfillment_order_id,
        image_alt_text,
        image_height,
        image_id,
        image_url,
        image_width,
        inventory_item_id,
        order_line_item_id,
        product_title,
        product_variant_id,
        remaining_quantity,
        requires_shipping,
        sku,
        total_quantity,
        variant_title,
        vendor,
        weight_unit,
        weight_value,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
