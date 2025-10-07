with source as (

    select * from {{ source('shopify_raw', 'customers') }}

),

renamed as (

    select
        -- ids
        id as customer_id,

        -- personal info
        email,
        phone,
        first_name,
        last_name,
        note,

        -- account info
        state as account_state,
        currency,
        created_at as created_timestamp,
        updated_at as updated_timestamp,

        -- flags
        tax_exempt as is_tax_exempt,
        verified_email as is_verified_email,

        -- marketing
        accepts_marketing as marketing_consent_state, -- boolean in new schema, was string in old
        marketing_opt_in_level,
        parse_timestamp('%Y-%m-%dT%H:%M:%E*SZ', json_extract_scalar(accepts_marketing_updated_at, '$')) as marketing_consent_updated_at, -- JSON string to timestamp

        -- default address (JSON column - extract id)
        cast(json_extract_scalar(default_address, '$.id') as int64) as default_address_id,

        -- metadata from Airbyte (replaces _fivetran_synced)
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation for multi-source support
        'airbyte' as source_relation,

        -- aggregates available directly in source (convenient!)
        total_spent,
        orders_count

    from source

)

select * from renamed
