with orders as (

    select *
    from {{ ref('stg_shopify__order') }}

), order_lines as (

    select *
    from {{ ref('shopify__orders__order_line_aggregates') }}

), joined as (

    select
        orders.*,
        order_lines.line_item_count
    from orders
    left join order_lines
        using (order_id)

), windows as (

    select 
        *,
        row_number() over (partition by customer_id order by created_timestamp) as customer_order_seq_number
    from joined

), new_vs_repeat as (

    select 
        *,
        case 
            when customer_order_seq_number = 1 then 'new'
            else 'repeat'
        end as new_vs_repeat
    from windows

)

select *
from new_vs_repeat