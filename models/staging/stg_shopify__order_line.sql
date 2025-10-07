with source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

unnested as (

    select
        -- parent order info
        id as order_id,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced,

        -- unnest line_items JSON array
        line_item

    from source,
    unnest(json_extract_array(line_items)) as line_item
    where line_items is not null

),

renamed as (

    select
        -- ids
        cast(json_extract_scalar(line_item, '$.id') as int64) as order_line_id,
        order_id,

        -- product info
        cast(json_extract_scalar(line_item, '$.product_id') as int64) as product_id,
        cast(json_extract_scalar(line_item, '$.variant_id') as int64) as variant_id,
        json_extract_scalar(line_item, '$.sku') as sku,
        json_extract_scalar(line_item, '$.vendor') as vendor,
        json_extract_scalar(line_item, '$.title') as title,
        json_extract_scalar(line_item, '$.variant_title') as variant_title,
        json_extract_scalar(line_item, '$.name') as name,

        -- quantities and amounts
        cast(json_extract_scalar(line_item, '$.quantity') as int64) as quantity,
        cast(json_extract_scalar(line_item, '$.grams') as int64) as grams,

        -- pricing
        cast(json_extract_scalar(line_item, '$.price') as numeric) as price,
        json_extract_scalar(line_item, '$.price_set') as price_set,
        cast(json_extract_scalar(line_item, '$.total_discount') as numeric) as total_discount,
        json_extract_scalar(line_item, '$.total_discount_set') as total_discount_set,

        -- pre-tax pricing
        cast(json_extract_scalar(line_item, '$.pre_tax_price') as numeric) as pre_tax_price,
        json_extract_scalar(line_item, '$.pre_tax_price_set') as pre_tax_price_set,

        -- fulfillment
        cast(json_extract_scalar(line_item, '$.fulfillable_quantity') as int64) as fulfillable_quantity,
        json_extract_scalar(line_item, '$.fulfillment_status') as fulfillment_status,
        json_extract_scalar(line_item, '$.fulfillment_service') as fulfillment_service,

        -- flags
        cast(json_extract_scalar(line_item, '$.gift_card') as bool) as is_gift_card,
        cast(json_extract_scalar(line_item, '$.requires_shipping') as bool) as is_shipping_required,
        cast(json_extract_scalar(line_item, '$.taxable') as bool) as is_taxable,

        -- tax
        json_extract_scalar(line_item, '$.tax_code') as tax_code,
        json_extract(line_item, '$.tax_lines') as tax_lines, -- keep as JSON, will parse in tax_line model

        -- properties
        json_extract(line_item, '$.properties') as properties,

        -- metadata
        source_relation,
        _fivetran_synced

    from unnested

)

select * from renamed
