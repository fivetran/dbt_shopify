with source as (

    select * from {{ source('salla_raw', 'products') }}

),

renamed as (

    select
        -- ids
        id as product_id,
        brand_id,
        category_id,

        -- product info
        name as product_name,
        sku,
        description,
        type as product_type,

        -- pricing
        price,
        sale_price,

        -- inventory
        quantity,
        weight,
        dimensions,

        -- flags
        is_digital,
        status,

        -- media
        images,

        -- options/variants
        options,
        variants,

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
