with source as (

    select * from {{ source('shopify_raw', 'transactions') }}

),

renamed as (

    select
        -- ids
        id as transaction_id,
        order_id,
        parent_id,
        user_id,
        location_id,
        device_id,

        -- amounts
        amount,
        amount_set, -- JSON

        -- transaction details
        kind,
        gateway,
        status,
        message,
        error_code,
        authorization as authorization_code,

        -- payment details
        payment_id,
        payment_details, -- JSON

        -- dates
        created_at as created_timestamp,
        processed_at as processed_timestamp,

        -- currency
        currency,

        -- flags
        test,

        -- metadata
        source_name,
        receipt, -- JSON

        -- fees
        fees, -- JSON

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
