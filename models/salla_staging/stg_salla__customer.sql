with source as (

    select * from {{ source('salla_raw', 'customers') }}

),

renamed as (

    select
        -- ids
        id as customer_id,

        -- personal info
        email,
        cast(mobile as string) as phone,
        first_name,
        last_name,

        -- location
        city,
        country,
        mobile_code,

        -- profile
        avatar,
        gender,

        -- groups (JSON array)
        `groups` as customer_groups,

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
