with source as (

    select * from {{ source('shopify_raw', 'products') }}

),

renamed as (

    select
        -- ids
        id as product_id,

        -- product info
        title,
        handle,
        product_type,
        vendor,
        status,
        published_scope,

        -- dates
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        published_at as published_timestamp,
        deleted_at,

        -- descriptions
        body_html,
        description,

        -- tags (comma-separated string)
        tags,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation,

        -- flags
        case when deleted_at is not null then true else false end as is_deleted

    from source

)

select * from renamed
