with source as (

    select * from {{ source('salla_raw', 'orders') }}

),

renamed as (

    select
        -- ids
        id as order_id,
        reference_id,
        customer_id,

        -- dates
        date as order_date,
        created_at as created_timestamp,
        updated_at as updated_timestamp,

        -- payment
        payment_method,

        -- JSON fields to parse
        items, -- order line items (JSON array)
        total, -- total amounts (JSON object)
        status, -- status info (JSON object)

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
