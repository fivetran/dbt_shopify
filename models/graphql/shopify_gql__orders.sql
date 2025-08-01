{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with orders as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'order_id']) }} as orders_unique_key
    from {{ ref('int_shopify_gql__order') }}

), order_lines as (

    select *
    from {{ ref('int_shopify_gql__orders_order_line_aggregates') }}

), fulfillments as (

    select *
    from {{ ref('int_shopify_gql__order_fulfillment_aggregates') }}
    
), order_adjustments as (

    select *
    from {{ ref('int_shopify_gql__order_adjustment') }}

), order_adjustments_aggregates as (
    select
        order_id,
        source_relation,
        sum(amount_shop) as order_adjustment_amount,
        sum(tax_amount_shop) as order_adjustment_tax_amount
    from order_adjustments
    group by 1,2

), refunds as (

    select *
    from {{ ref('int_shopify_gql__orders_order_refunds') }}

), refund_aggregates as (
    select
        order_id,
        source_relation,
        sum(subtotal) as refund_subtotal,
        sum(total_tax) as refund_total_tax
    from refunds
    group by 1,2

), order_discount_code as (
    
    select *
    from {{ ref('int_shopify_gql__order_discount_code') }}

), discount_aggregates as (

    select 
        order_id,
        source_relation,
        sum(case when type = 'shipping' then value_amount else 0 end) as shipping_discount_amount,
        sum(case when type = 'percentage' then value_amount else 0 end) as percentage_calc_discount_amount,
        sum(case when type = 'fixed_amount' then value_amount else 0 end) as fixed_amount_discount_amount,
        count(distinct code) as count_discount_codes_applied

    from order_discount_code
    group by 1,2

), order_tag as (

    select
        order_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(value as " ~ dbt.type_string() ~ ")", "', '") }} as order_tags
    
    from {{ var('shopify_gql_order_tag') }}
    group by 1,2

), joined as (

    select
        orders.*,
        order_adjustments_aggregates.order_adjustment_amount,
        order_adjustments_aggregates.order_adjustment_tax_amount,
        refund_aggregates.refund_subtotal,
        refund_aggregates.refund_total_tax,
        (orders.total_price_shop_amount
            + coalesce(order_adjustments_aggregates.order_adjustment_amount,0) + coalesce(order_adjustments_aggregates.order_adjustment_tax_amount,0) 
            - coalesce(refund_aggregates.refund_subtotal,0) - coalesce(refund_aggregates.refund_total_tax,0)) as order_adjusted_total,
        order_lines.line_item_count,
        order_lines.total_line_items_price_pres_amount,
        order_lines.total_line_items_price_shop_amount,
        order_lines.total_line_items_price_pres_currency_codes,
        order_lines.total_line_items_price_shop_currency_codes,
        coalesce(discount_aggregates.shipping_discount_amount, 0) as shipping_discount_amount,
        coalesce(discount_aggregates.percentage_calc_discount_amount, 0) as percentage_calc_discount_amount,
        coalesce(discount_aggregates.fixed_amount_discount_amount, 0) as fixed_amount_discount_amount,
        coalesce(discount_aggregates.count_discount_codes_applied, 0) as count_discount_codes_applied,
        coalesce(order_lines.order_total_shipping_tax, 0) as order_total_shipping_tax,
        order_tag.order_tags,
        fulfillments.number_of_fulfillments,
        fulfillments.fulfillment_services,
        fulfillments.tracking_companies,
        fulfillments.tracking_numbers

    from orders
    left join order_lines
        on orders.order_id = order_lines.order_id
        and orders.source_relation = order_lines.source_relation
    left join refund_aggregates
        on orders.order_id = refund_aggregates.order_id
        and orders.source_relation = refund_aggregates.source_relation
    left join order_adjustments_aggregates
        on orders.order_id = order_adjustments_aggregates.order_id
        and orders.source_relation = order_adjustments_aggregates.source_relation
    left join discount_aggregates
        on orders.order_id = discount_aggregates.order_id 
        and orders.source_relation = discount_aggregates.source_relation
    left join order_tag
        on orders.order_id = order_tag.order_id
        and orders.source_relation = order_tag.source_relation
    left join fulfillments
        on orders.order_id = fulfillments.order_id
        and orders.source_relation = fulfillments.source_relation

), windows as (

    select 
        *,
        row_number() over (
            partition by {{ shopify.shopify_partition_by_cols('customer_id', 'source_relation') }}
            order by created_timestamp) 
            as customer_order_seq_number
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
