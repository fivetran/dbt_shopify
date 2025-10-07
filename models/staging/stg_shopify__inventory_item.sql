with source as (

    select * from {{ source('shopify_raw', 'inventory_items') }}

),

renamed as (

    select
        -- ids
        id as inventory_item_id,

        -- inventory info
        sku,
        cost as unit_cost_amount,
        currency_code as unit_cost_currency_code,
        tracked as is_inventory_quantity_tracked,
        requires_shipping as is_shipping_required,

        -- origin
        country_code_of_origin,
        province_code_of_origin,

        -- dates
        created_at as inventory_item_created_at,
        updated_at as inventory_item_updated_at,

        -- other
        harmonized_system_code,
        duplicate_sku_count,

        -- flags
        cast(null as bool) as is_inventory_item_deleted, -- not available in new schema

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
