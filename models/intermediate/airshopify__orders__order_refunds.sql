with refunds as (

    select * from {{ ref('stg_shopify__refund') }}

),

refund_line_items_unnested as (

    select
        refund_id,
        order_id,
        source_relation,
        refund_line_item

    from refunds,
    unnest(json_extract_array(refund_line_items)) as refund_line_item
    where refund_line_items is not null

),

refund_line_items_parsed as (

    select
        order_id,
        source_relation,
        cast(json_extract_scalar(refund_line_item, '$.quantity') as int64) as quantity,
        cast(json_extract_scalar(refund_line_item, '$.subtotal') as numeric) as subtotal,
        cast(json_extract_scalar(refund_line_item, '$.total_tax') as numeric) as total_tax

    from refund_line_items_unnested

),

aggregated as (

    select
        order_id,
        source_relation,
        sum(subtotal) as subtotal,
        sum(total_tax) as total_tax

    from refund_line_items_parsed
    group by 1, 2

)

select * from aggregated
