with source as (

    select * from {{ source('salla_raw', 'product_variants') }}

),

renamed as (

    select
        -- ids
        id as variant_id,
        product_id,

        -- variant info
        sku,
        barcode,
        options,

        -- pricing
        price,
        sale_price,

        -- inventory
        quantity,
        weight,
        dimensions,

        -- media
        image,

        -- status
        status,

        -- dates
        created_at as created_timestamp,
        updated_at as updated_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
