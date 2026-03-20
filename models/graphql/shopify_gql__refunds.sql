{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with refunds as (

    select *
    from {{ ref('stg_shopify_gql__refund') }}

), orders as (

    select
        order_id,
        source_relation,
        customer_id,
        email,
        source_name,
        created_timestamp as order_created_at
    from {{ ref('int_shopify_gql__order') }}

), order_adjustment_aggregates as (

    select
        refund_id,
        source_relation,
        sum(amount_shop) as refund_discrepancy_shop_amount,
        sum(tax_amount_shop) as refund_discrepancy_tax_shop_amount,
        sum(amount_pres) as refund_discrepancy_pres_amount,
        sum(tax_amount_pres) as refund_discrepancy_tax_pres_amount
    from {{ ref('stg_shopify_gql__order_adjustment') }}
    where lower(reason) = 'refund_discrepancy'
    group by 1, 2

), refund_line_aggregates as (

    select
        refund_id,
        source_relation,
        count(*) as count_refund_line_items,
        sum(quantity) as total_quantity_refunded,
        sum(coalesce(subtotal_shop_amount, 0)) as subtotal_shop_amount,
        sum(coalesce(total_tax_shop_amount, 0)) as total_tax_shop_amount,
        sum(coalesce(subtotal_shop_amount, 0)) + sum(coalesce(total_tax_shop_amount, 0)) as total_refunded_shop_amount,
        sum(coalesce(subtotal_pres_amount, 0)) as subtotal_pres_amount,
        sum(coalesce(total_tax_pres_amount, 0)) as total_tax_pres_amount,
        sum(coalesce(subtotal_pres_amount, 0)) + sum(coalesce(total_tax_pres_amount, 0)) as total_refunded_pres_amount,
        sum(case when restock_type in ('return', 'cancel', 'legacy_restock') then quantity else 0 end) as quantity_restocked,
        count(case when restock_type in ('return', 'cancel', 'legacy_restock') then 1 end) as count_restocked_line_items
    from {{ ref('stg_shopify_gql__order_line_refund') }}
    group by 1, 2

{% if var('shopify_gql_using_return', False) %}
), returns as (

    select *
    from {{ ref('stg_shopify_gql__return') }}

), return_shipping_fee_aggregates as (

    select
        return_id,
        source_relation,
        sum(amount_shop_amount) as return_shipping_fee_shop_amount,
        sum(amount_pres_amount) as return_shipping_fee_pres_amount,
        {{ fivetran_utils.string_agg("distinct cast(amount_pres_currency_code as " ~ dbt.type_string() ~ ")", "', '") }} as return_shipping_fee_pres_currency_codes
    from {{ ref('stg_shopify_gql__return_shipping_fee') }}
    group by 1, 2
{% endif %}

), joined as (

    select
        -- identity / keys
        {{ dbt_utils.generate_surrogate_key(['refunds.refund_id', 'refunds.source_relation']) }} as unique_key,
        refunds.refund_id,
        refunds.source_relation,
        refunds.return_id,
        refunds.order_id,

        -- order context
        orders.customer_id,
        orders.email,
        orders.source_name as order_channel,
        orders.order_created_at,

        -- timing
        refunds.created_at as refund_created_at,
        refunds.updated_at as refund_updated_at,
        {{ dbt.datediff('cast(orders.order_created_at as date)', 'cast(refunds.created_at as date)', 'day') }} as days_to_refund,

        -- refund metadata
        refunds.note as refund_note,
        refunds.user_id as staff_user_id,

        -- shopify-reported header total (for reconciliation against line item sum)
        refunds.total_refunded_shop_amount as shopify_total_refunded_shop_amount,
        refunds.total_refunded_pres_amount as shopify_total_refunded_pres_amount,
        refunds.total_refunded_pres_currency_code,

        -- line item aggregates (shop currency)
        coalesce(refund_line_aggregates.count_refund_line_items, 0) as count_refund_line_items,
        coalesce(refund_line_aggregates.total_quantity_refunded, 0) as total_quantity_refunded,
        coalesce(refund_line_aggregates.subtotal_shop_amount, 0) as subtotal_shop_amount,
        coalesce(refund_line_aggregates.total_tax_shop_amount, 0) as total_tax_shop_amount,
        coalesce(refund_line_aggregates.total_refunded_shop_amount, 0) as total_refunded_shop_amount,

        -- line item aggregates (presentment currency)
        coalesce(refund_line_aggregates.subtotal_pres_amount, 0) as subtotal_pres_amount,
        coalesce(refund_line_aggregates.total_tax_pres_amount, 0) as total_tax_pres_amount,
        coalesce(refund_line_aggregates.total_refunded_pres_amount, 0) as total_refunded_pres_amount,

        -- restock summary
        coalesce(refund_line_aggregates.quantity_restocked, 0) as quantity_restocked,
        coalesce(refund_line_aggregates.count_restocked_line_items, 0) as count_restocked_line_items,
        coalesce(refund_line_aggregates.count_restocked_line_items, 0) > 0 as has_restock,

        -- discrepancy adjustment (difference between sum of line items and actual amount processed)
        order_adjustment_aggregates.refund_discrepancy_shop_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_shop_amount,
        order_adjustment_aggregates.refund_discrepancy_pres_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_pres_amount

        {% if var('shopify_gql_using_return', False) %}
        -- return context (only when shopify_gql_using_return is enabled)
        , returns.return_id is not null as has_return
        , returns.name as return_name
        , returns.status as return_status
        , returns.decline_reason as return_decline_reason
        , returns.decline_note as return_decline_note

        -- return shipping cost (what merchant charges/absorbs for return shipment)
        , coalesce(return_shipping_fee_aggregates.return_shipping_fee_shop_amount, 0) as return_shipping_fee_shop_amount
        , coalesce(return_shipping_fee_aggregates.return_shipping_fee_pres_amount, 0) as return_shipping_fee_pres_amount
        , return_shipping_fee_aggregates.return_shipping_fee_pres_currency_codes
        {% endif %}

    from refunds
    left join orders
        on refunds.order_id = orders.order_id
        and refunds.source_relation = orders.source_relation
    left join refund_line_aggregates
        on refunds.refund_id = refund_line_aggregates.refund_id
        and refunds.source_relation = refund_line_aggregates.source_relation
    left join order_adjustment_aggregates
        on refunds.refund_id = order_adjustment_aggregates.refund_id
        and refunds.source_relation = order_adjustment_aggregates.source_relation
    {% if var('shopify_gql_using_return', False) %}
    left join returns
        on refunds.return_id = returns.return_id
        and refunds.source_relation = returns.source_relation
    left join return_shipping_fee_aggregates
        on refunds.return_id = return_shipping_fee_aggregates.return_id
        and refunds.source_relation = return_shipping_fee_aggregates.source_relation
    {% endif %}

)

select *
from joined
