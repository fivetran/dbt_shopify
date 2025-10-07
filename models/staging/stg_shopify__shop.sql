with source as (

    select * from {{ source('shopify_raw', 'shop') }}

),

renamed as (

    select
        -- ids
        id as shop_id,

        -- shop info
        name,
        domain,
        email as shop_owner_email,
        shop_owner,

        -- settings
        currency,
        enabled_presentment_currencies,
        iana_timezone,
        timezone,
        weight_unit,

        -- dates
        created_at,
        updated_at,

        -- flags
        cast(null as bool) as is_deleted, -- not available in new schema

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
