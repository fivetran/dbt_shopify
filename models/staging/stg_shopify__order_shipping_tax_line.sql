with source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

shipping_lines_unnested as (

    select
        id as order_id,
        row_number() over (partition by id order by (select null)) as shipping_line_index,
        shipping_line,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced

    from source,
    unnest(json_extract_array(shipping_lines)) as shipping_line
    where shipping_lines is not null

),

tax_lines_unnested as (

    select
        order_id,
        shipping_line_index as order_shipping_line_id, -- use index as synthetic id
        tax_line,
        source_relation,
        _fivetran_synced

    from shipping_lines_unnested,
    unnest(json_extract_array(json_extract(shipping_line, '$.tax_lines'))) as tax_line
    where json_extract(shipping_line, '$.tax_lines') is not null

),

renamed as (

    select
        -- ids
        order_id,
        order_shipping_line_id,
        row_number() over (partition by order_id, order_shipping_line_id order by (select null)) as tax_line_index,

        -- tax details
        json_extract_scalar(tax_line, '$.title') as title,
        cast(json_extract_scalar(tax_line, '$.rate') as numeric) as rate,
        cast(json_extract_scalar(tax_line, '$.price') as numeric) as price,
        json_extract_scalar(tax_line, '$.price_set') as price_set,

        -- metadata
        source_relation,
        _fivetran_synced

    from tax_lines_unnested

)

select * from renamed
