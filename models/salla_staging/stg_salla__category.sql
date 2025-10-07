with source as (

    select * from {{ source('salla_raw', 'categories') }}

),

renamed as (

    select
        -- ids
        id as category_id,
        parent_id,

        -- category info
        name as category_name,
        status,
        sort_order,

        -- media
        image,

        -- hierarchy
        sub_categories,

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
