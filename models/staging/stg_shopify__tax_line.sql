with orders_source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

-- Tax lines at order level
order_tax_lines as (

    select
        id as order_id,
        null as order_line_id,
        'order' as tax_line_source,
        tax_line,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced

    from orders_source,
    unnest(json_extract_array(tax_lines)) as tax_line
    where tax_lines is not null

),

-- Tax lines at order line item level
order_line_tax_lines as (

    select
        id as order_id,
        cast(json_extract_scalar(line_item, '$.id') as int64) as order_line_id,
        'order_line' as tax_line_source,
        tax_line,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced

    from orders_source,
    unnest(json_extract_array(line_items)) as line_item,
    unnest(json_extract_array(json_extract(line_item, '$.tax_lines'))) as tax_line
    where line_items is not null
    and json_extract(line_item, '$.tax_lines') is not null

),

combined as (

    select * from order_tax_lines
    union all
    select * from order_line_tax_lines

),

renamed as (

    select
        -- ids
        order_id,
        order_line_id,
        row_number() over (partition by order_id, order_line_id order by tax_line) as tax_line_index,

        -- tax details
        json_extract_scalar(tax_line, '$.title') as title,
        cast(json_extract_scalar(tax_line, '$.rate') as numeric) as rate,
        cast(json_extract_scalar(tax_line, '$.price') as numeric) as price,
        json_extract_scalar(tax_line, '$.price_set') as price_set,

        -- channel liability
        json_extract_scalar(tax_line, '$.channel_liable') as channel_liable,

        -- source
        tax_line_source,

        -- metadata
        source_relation,
        _fivetran_synced

    from combined

)

select * from renamed
