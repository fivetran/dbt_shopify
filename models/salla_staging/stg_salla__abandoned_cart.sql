with source as (

    select * from {{ source('salla_raw', 'abandoned_carts') }}

),

renamed as (

    select
        -- ids
        id as abandoned_cart_id,

        -- customer info - parse from JSON
        cast(json_extract_scalar(customer, '$.id') as int64) as customer_id,
        json_extract_scalar(customer, '$.email') as customer_email,
        json_extract_scalar(customer, '$.name') as customer_name,

        -- cart details
        items,

        -- amounts - parse from JSON
        cast(json_extract_scalar(total, '$.amount') as numeric) as total_amount,
        json_extract_scalar(total, '$.currency') as currency,
        cast(json_extract_scalar(subtotal, '$.amount') as numeric) as subtotal_amount,
        cast(json_extract_scalar(total_discount, '$.amount') as numeric) as total_discount_amount,

        -- coupon - parse from JSON
        cast(json_extract_scalar(coupon, '$.id') as int64) as coupon_id,
        json_extract_scalar(coupon, '$.code') as coupon_code,

        -- urls
        checkout_url,

        -- metrics
        age_in_minutes,

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
