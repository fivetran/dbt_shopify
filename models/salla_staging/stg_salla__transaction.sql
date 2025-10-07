with source as (

    select * from {{ source('salla_raw', 'transactions') }}

),

renamed as (

    select
        -- ids
        id as transaction_id,
        order_id,
        transaction_id as gateway_transaction_id,

        -- transaction info
        type as transaction_type,
        status as transaction_status,
        payment_method,

        -- amounts
        amount,
        currency,

        -- gateway response
        gateway_response,

        -- dates
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        processed_at as processed_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
