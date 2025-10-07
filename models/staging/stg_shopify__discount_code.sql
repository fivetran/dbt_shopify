with source as (

    select * from {{ source('shopify_raw', 'discount_codes') }}

),

renamed as (

    select
        -- ids
        id as discount_code_id,
        price_rule_id,

        -- code
        code,
        title,

        -- settings
        discount_type,
        applies_once_per_customer,
        usage_count,
        usage_limit,
        status,

        -- dates
        starts_at,
        ends_at,
        created_at,
        updated_at,

        -- totals from GraphQL
        cast(json_extract_scalar(total_sales, '$.amount') as numeric) as total_sales_amount,
        json_extract_scalar(total_sales, '$.currency_code') as total_sales_currency_code,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
