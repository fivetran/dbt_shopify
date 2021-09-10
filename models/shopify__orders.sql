with orders as (

    select *
    from {{ var('shopify_order') }}

), order_lines as (

    select *
    from {{ ref('shopify__orders__order_line_aggregates') }}

{% if var('shopify__using_order_adjustment', true) %}
), order_adjustments as (

    select *
    from {{ var('shopify_order_adjustment') }}

), order_adjustments_aggregates as (
    select
        order_id,
        source_relation,
        sum(amount) as order_adjustment_amount,
        sum(tax_amount) as order_adjustment_tax_amount
    from order_adjustments
    group by 1,2
{% endif %}

{% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
), refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), refund_aggregates as (
    select
        order_id,
        source_relation,
        sum(subtotal) as refund_subtotal,
        sum(total_tax) as refund_total_tax
    from refunds
    group by 1,2
{% endif %}

), joined as (

    select
        orders.*,
        coalesce(cast({{ fivetran_utils.json_parse("total_shipping_price_set",["shop_money","amount"]) }} as {{ dbt_utils.type_float() }}) ,0) as shipping_cost,
        
        {% if var('shopify__using_order_adjustment', true) %}
        order_adjustments_aggregates.order_adjustment_amount,
        order_adjustments_aggregates.order_adjustment_tax_amount,
        {% endif %}

        {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
        refund_aggregates.refund_subtotal,
        refund_aggregates.refund_total_tax,
        {% endif %}
        (orders.total_price
            {% if var('shopify__using_order_adjustment', true) %}
            + coalesce(order_adjustments_aggregates.order_adjustment_amount,0) + coalesce(order_adjustments_aggregates.order_adjustment_tax_amount,0) 
            {% endif %}
            {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
            - coalesce(refund_aggregates.refund_subtotal,0) - coalesce(refund_aggregates.refund_total_tax,0)
            {% endif %} ) as order_adjusted_total,
        order_lines.line_item_count
    from orders
    left join order_lines
        on orders.order_id = order_lines.order_id
        and orders.source_relation = order_lines.source_relation

    {% if fivetran_utils.enabled_vars(vars=["shopify__using_order_line_refund", "shopify__using_refund"]) %}
    left join refund_aggregates
        on orders.order_id = refund_aggregates.order_id
        and orders.source_relation = refund_aggregates.source_relation
    {% endif %}
    {% if var('shopify__using_order_adjustment', true) %}
    left join order_adjustments_aggregates
        on orders.order_id = order_adjustments_aggregates.order_id
        and orders.source_relation = order_adjustments_aggregates.source_relation
    {% endif %}

), windows as (

    select 
        *,
        row_number() over (partition by customer_id, source_relation order by created_timestamp) as customer_order_seq_number
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
