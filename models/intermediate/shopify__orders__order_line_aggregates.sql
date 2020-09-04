with order_line as (

    select *
    from {{ ref('stg_shopify__order_line') }}

), aggregated as (

    select 
        order_id,
        count(*) as line_item_count
    from order_line
    group by 1

)

select *
from aggregated