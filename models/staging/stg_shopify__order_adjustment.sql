with source as (

    select * from {{ source('shopify_raw', 'order_refunds') }}

),

unnested as (

    select
        order_id,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced,
        order_adjustment

    from source,
    unnest(json_extract_array(order_adjustments)) as order_adjustment
    where order_adjustments is not null

),

renamed as (

    select
        -- ids
        cast(json_extract_scalar(order_adjustment, '$.id') as int64) as order_adjustment_id,
        order_id,
        cast(json_extract_scalar(order_adjustment, '$.refund_id') as int64) as refund_id,

        -- amounts
        cast(json_extract_scalar(order_adjustment, '$.amount') as numeric) as amount,
        cast(json_extract_scalar(order_adjustment, '$.tax_amount') as numeric) as tax_amount,

        -- details
        json_extract_scalar(order_adjustment, '$.kind') as kind,
        json_extract_scalar(order_adjustment, '$.reason') as reason,

        -- metadata
        source_relation,
        _fivetran_synced

    from unnested

)

select * from renamed
