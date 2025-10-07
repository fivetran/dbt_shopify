with source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

unnested as (

    select
        -- parent order info
        id as order_id,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced,

        -- unnest shipping_lines JSON array
        shipping_line

    from source,
    unnest(json_extract_array(shipping_lines)) as shipping_line
    where shipping_lines is not null

),

renamed as (

    select
        -- generate synthetic id from order_id + index (shipping lines don't have their own id)
        order_id,
        row_number() over (partition by order_id order by shipping_line) as shipping_line_index,
        row_number() over (partition by order_id order by shipping_line) as order_shipping_line_id,

        -- shipping details
        json_extract_scalar(shipping_line, '$.code') as code,
        json_extract_scalar(shipping_line, '$.title') as title,
        json_extract_scalar(shipping_line, '$.source') as source,

        -- pricing
        cast(json_extract_scalar(shipping_line, '$.price') as numeric) as price,
        json_extract_scalar(shipping_line, '$.price_set') as price_set,

        -- discounts
        cast(json_extract_scalar(shipping_line, '$.discounted_price') as numeric) as discounted_price,
        json_extract_scalar(shipping_line, '$.discounted_price_set') as discounted_price_set,
        json_extract(shipping_line, '$.discount_allocations') as discount_allocations,

        -- carrier
        json_extract_scalar(shipping_line, '$.carrier_identifier') as carrier_identifier,
        json_extract_scalar(shipping_line, '$.requested_fulfillment_service_id') as requested_fulfillment_service_id,

        -- tax lines (nested JSON array)
        json_extract(shipping_line, '$.tax_lines') as tax_lines,

        -- metadata
        source_relation,
        _fivetran_synced

    from unnested

)

select * from renamed
