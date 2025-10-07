with source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

unnested as (

    select
        id as order_id,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced,
        discount_code

    from source,
    unnest(json_extract_array(discount_codes)) as discount_code
    where discount_codes is not null

),

renamed as (

    select
        -- ids
        order_id,

        -- discount code details
        json_extract_scalar(discount_code, '$.code') as code,
        json_extract_scalar(discount_code, '$.type') as type,
        cast(json_extract_scalar(discount_code, '$.amount') as numeric) as amount,

        -- metadata
        source_relation,
        _fivetran_synced

    from unnested

)

select * from renamed
