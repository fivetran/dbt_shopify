with source as (

    select * from {{ source('shopify_raw', 'inventory_levels') }}

),

renamed as (

    select
        -- ids
        cast(id as int64) as inventory_level_id,
        inventory_item_id,
        location_id,

        -- quantities
        available,

        -- flags
        can_deactivate,
        deactivation_alert,

        -- dates
        created_at,
        updated_at,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
