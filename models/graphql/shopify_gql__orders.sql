{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

{% set metafields_enabled = var('shopify_gql_using_metafield', True) and (var('shopify_using_all_metafields', True) or var('shopify_using_order_metafields', True)) %}

with orders as (

    select *
    from {{ ref('shopify_gql__order_metafields') if metafields_enabled else ref('int_shopify_gql__order') }}

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

), discount_code_aggregates as (

    -- This aggregates discount CODE metadata (type, count)
    select
        order_id,
        source_relation,
        sum(case when type = 'shipping' then value_amount else 0 end) as shipping_discount_amount,
        sum(case when type = 'percentage' then value_amount else 0 end) as percentage_calc_discount_amount,
        sum(case when type = 'fixed_amount' then value_amount else 0 end) as fixed_amount_discount_amount,
        count(distinct code) as count_discount_codes_applied

    from order_discount_code
    group by 1,2

), discount_aggregates as (

    -- NEW: Actual discount amounts from DISCOUNT_ALLOCATION (Customer Fix #2)
    select *
    from {{ ref('int_shopify_gql__discount_aggregates') }}

), refund_adjustments as (

    -- NEW: Refund discrepancy adjustments (Customer Fix #4)
    select *
    from {{ ref('int_shopify_gql__refund_adjustments_aggregates') }}

), order_tag as (

    select
        order_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(value as " ~ dbt.type_string() ~ ")", "', '") }} as order_tags
    
    from {{ ref('stg_shopify_gql__order_tag') }}
    group by 1,2

), joined as (

    select
        orders.*,
        order_adjustments_aggregates.order_adjustment_amount,
        order_adjustments_aggregates.order_adjustment_tax_amount,
        refund_aggregates.refund_subtotal,
        refund_aggregates.refund_total_tax,

        -- NEW: Include refund discrepancy adjustment fields (Customer Fix #4)
        refund_adjustments.order_refund_discrepancy_amount,
        refund_adjustments.order_refund_discrepancy_tax,

        -- UPDATED: order_adjusted_total now accounts for refund discrepancies (Customer Fix #4)
        (orders.total_price_shop_amount
            + coalesce(order_adjustments_aggregates.order_adjustment_amount,0)
            + coalesce(order_adjustments_aggregates.order_adjustment_tax_amount,0)
            - coalesce(refund_aggregates.refund_subtotal,0)
            - coalesce(refund_aggregates.refund_total_tax,0)
            + coalesce(refund_adjustments.order_refund_discrepancy_amount, 0)  -- Add back discrepancies
            + coalesce(refund_adjustments.order_refund_discrepancy_tax, 0)
        ) as order_adjusted_total,

        order_lines.line_item_count,

        -- UPDATED: These now exclude gift cards (Customer Fix #1)
        order_lines.total_line_items_price_pres_amount,
        order_lines.total_line_items_price_shop_amount,

        -- NEW: Gift card sales tracked separately for transparency (Customer Fix #1)
        order_lines.total_gift_card_sales_shop_amount,
        order_lines.total_gift_card_sales_pres_amount,

        order_lines.total_line_items_price_pres_currency_codes,
        order_lines.total_line_items_price_shop_currency_codes,

        -- Discount code metadata (unchanged)
        coalesce(discount_code_aggregates.shipping_discount_amount, 0) as shipping_discount_amount,
        coalesce(discount_code_aggregates.percentage_calc_discount_amount, 0) as percentage_calc_discount_amount,
        coalesce(discount_code_aggregates.fixed_amount_discount_amount, 0) as fixed_amount_discount_amount,
        coalesce(discount_code_aggregates.count_discount_codes_applied, 0) as count_discount_codes_applied,

        -- NEW: Actual discount amount from DISCOUNT_ALLOCATION (Customer Fix #2)
        coalesce(discount_aggregates.order_total_discount_shop_amount, 0) as total_discounts_shop_amount,
        coalesce(discount_aggregates.order_total_discount_pres_amount, 0) as total_discounts_pres_amount,

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

    -- NEW: Join to refund discrepancy adjustments (Customer Fix #4)
    left join refund_adjustments
        on orders.order_id = refund_adjustments.order_id
        and orders.source_relation = refund_adjustments.source_relation

    -- Discount code aggregates (metadata only)
    left join discount_code_aggregates
        on orders.order_id = discount_code_aggregates.order_id
        and orders.source_relation = discount_code_aggregates.source_relation

    -- NEW: Actual discount amounts from DISCOUNT_ALLOCATION (Customer Fix #2)
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