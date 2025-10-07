{{ config(materialized='table') }}

with order_items as (

    select *
    from {{ ref('stg_salla__order_item') }}

), order_item_aggregates as (

    select
        order_id,
        source_relation,
        count(*) as line_item_count,
        sum(quantity) as order_total_quantity,
        sum(total_price) as order_total_line_items_price

    from order_items
    group by 1,2

)

select *
from order_item_aggregates
