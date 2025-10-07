with source as (

    select * from {{ source('salla_raw', 'coupons') }}

),

renamed as (

    select
        -- ids
        id as coupon_id,

        -- coupon info
        code,
        name,
        type as coupon_type,
        value as coupon_value,

        -- constraints
        minimum_amount,
        usage_limit,
        used_count,

        -- status
        is_active,

        -- dates
        starts_at as start_timestamp,
        expires_at as expiration_timestamp,
        created_at as created_timestamp,
        updated_at as updated_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
