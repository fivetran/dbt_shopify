with source as (

    select * from {{ source('salla_raw', 'brands') }}

),

renamed as (

    select
        -- ids
        id as brand_id,

        -- brand info
        name as brand_name,
        description,
        ar_char,
        en_char,

        -- media
        logo,
        banner,

        -- metadata
        metadata,

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
