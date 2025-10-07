with source as (

    select * from {{ source('salla_raw', 'coupon_codes') }}

),

renamed as (

    select
        -- ids
        id as coupon_code_id,
        coupon_id,

        -- code info
        code,
        usage_count,

        -- status
        is_active,

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
