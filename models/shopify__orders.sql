with orders as (

    select *
    from {{ var('shopify_order') }}

), order_lines as (

    select *
    from {{ ref('shopify__orders__order_line_aggregates') }}

), refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), order_adjustments as (

    select *
    from {{ var('shopify_order_adjustment') }}

), refund_aggregates as (
    select
        order_id,
        sum(subtotal) as refund_subtotal,
        sum(total_tax) as refund_total_tax
    from refunds
    group by 1

), order_adjustments_aggregates as (
    select
        order_id,
        sum(amount) as order_adjustment_amount,
        sum(tax_amount) as order_adjustment_tax_amount
    from order_adjustments
    group by 1

), joined as (

    select
        orders.*,
        coalesce(cast({{ fivetran_utils.json_parse("total_shipping_price_set",["shop_money","amount"]) }} as {{ dbt_utils.type_float() }}) ,0) as shipping_cost,
        order_adjustments_aggregates.order_adjustment_amount,
        order_adjustments_aggregates.order_adjustment_tax_amount,
        refund_aggregates.refund_subtotal,
        refund_aggregates.refund_total_tax,
        (orders.total_price + coalesce(order_adjustments_aggregates.order_adjustment_amount,0) + coalesce(order_adjustments_aggregates.order_adjustment_tax_amount,0) - coalesce(refund_aggregates.refund_subtotal,0) - coalesce(refund_aggregates.refund_total_tax,0)) as order_adjusted_total,
        order_lines.line_item_count
    from orders
    left join order_lines
        using (order_id)
    left join refund_aggregates
        using (order_id)
    left join order_adjustments_aggregates
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