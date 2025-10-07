with source as (

    select * from {{ source('shopify_raw', 'locations') }}

),

renamed as (

    select
        -- ids
        id as location_id,

        -- location info
        name as location_name,
        address1 as address_1,
        address2 as address_2,
        city,
        province,
        province_code,
        country,
        country_code,
        zip,
        phone,

        -- flags
        active as is_location_active,
        legacy as is_legacy_location,
        cast(null as bool) as is_location_deleted, -- not available in new schema

        -- dates
        created_at as location_created_at,
        updated_at as location_updated_at,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
