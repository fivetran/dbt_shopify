with source as (

    select * from {{ source('salla_raw', 'order_items') }}

),

renamed as (

    select
        -- ids
        id as order_item_id,
        order_id,
        product_id,
        variant_id,

        -- product info
        product_name,
        product_sku,
        product_options,

        -- pricing
        unit_price,
        total_price,
        quantity,

        -- dates
        created_at as created_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
