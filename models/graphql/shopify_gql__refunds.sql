{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with refunds as (

    select *
    from {{ ref('stg_shopify_gql__refund') }}

), order_line_refunds as (

    select *
    from {{ ref('stg_shopify_gql__order_line_refund') }}

), order_lines as (

    select
        order_line_id,
        order_id,
        source_relation,
        product_id,
        variant_id,
        title,
        sku,
        vendor,
        is_gift_card,
        price_shop_amount                                               as original_total_price_shop_amount,
        price_pres_amount                                               as original_total_price_pres_amount,
        price_pres_currency_code                                        as original_total_price_pres_currency_code
    from {{ ref('stg_shopify_gql__order_line') }}

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

    -- Refund discrepancy adjustments are refund-level corrections applied when the sum of
    -- line item refunds does not exactly match the total refund amount processed.
    -- Caution: this amount repeats across all order_line_refund rows for the same refund_id.
    -- Do not sum this field when aggregating at the order_line_refund grain.
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

{% if var('shopify_gql_using_return', False) %}
), returns as (

    select *
    from {{ ref('stg_shopify_gql__return') }}

), return_line_items as (

    select *
    from {{ ref('stg_shopify_gql__return_line_item') }}

), return_shipping_fee_aggregates as (

    -- Aggregated at return level since a return can have multiple shipping fees.
    -- Caution: these amounts repeat across all order_line_refund rows for the same return_id.
    -- Do not sum these fields when aggregating at the order_line_refund grain.
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
        {{ dbt_utils.generate_surrogate_key([
            'order_line_refunds.order_line_refund_id',
            'order_line_refunds.source_relation'
        ]) }} as unique_key,
        refunds.refund_id,
        refunds.return_id,
        order_line_refunds.order_line_refund_id,
        order_line_refunds.order_line_id,
        refunds.order_id,

        -- order context
        orders.customer_id,
        orders.email,
        orders.source_name as order_channel,
        orders.order_created_at,

        -- timing (note: Fivetran does not sync processed_at from the GraphQL Refund object)
        refunds.created_at as refund_created_at,
        refunds.updated_at as refund_updated_at,
        {{ dbt.datediff('cast(orders.order_created_at as date)', 'cast(refunds.created_at as date)', 'day') }} as days_to_refund,

        -- refund metadata
        refunds.note as refund_note,
        refunds.user_id as staff_user_id,

        -- refund header totals (pre-aggregated by Shopify at the refund level)
        -- note: these repeat across all order_line_refund rows for the same refund
        refunds.total_refunded_shop_amount,
        refunds.total_refunded_pres_amount,
        refunds.total_refunded_pres_currency_code,

        {% if var('shopify_gql_using_return', False) %}
        -- return lifecycle (null when refund was not initiated via a return request)
        returns.return_id is not null as has_return,
        returns.name as return_name,
        returns.status as return_status,
        returns.decline_reason as return_decline_reason,
        returns.decline_note as return_decline_note,

        -- return line item detail (why the customer returned this specific item)
        return_line_items.return_reason,
        return_line_items.return_reason_note,
        return_line_items.customer_note as return_customer_note,
        return_line_items.quantity as return_requested_quantity,
        return_line_items.refundable_quantity,
        return_line_items.refunded_quantity,
        -- items physically returned but not yet financially processed
        (coalesce(return_line_items.refundable_quantity, 0) - coalesce(return_line_items.refunded_quantity, 0)) as pending_refund_quantity,

        -- return shipping cost (what merchant charges/absorbs for return shipment)
        coalesce(return_shipping_fee_aggregates.return_shipping_fee_shop_amount, 0) as return_shipping_fee_shop_amount,
        coalesce(return_shipping_fee_aggregates.return_shipping_fee_pres_amount, 0) as return_shipping_fee_pres_amount,
        return_shipping_fee_aggregates.return_shipping_fee_pres_currency_codes,
        {% endif %}

        -- product context (values at time of original order)
        order_lines.product_id,
        order_lines.variant_id,
        order_lines.title as product_title,
        order_lines.sku,
        order_lines.vendor,
        order_lines.original_total_price_shop_amount,
        order_lines.original_total_price_pres_amount,
        order_lines.original_total_price_pres_currency_code,
        order_lines.is_gift_card,

        -- refund line financials (shop currency)
        order_line_refunds.quantity as refund_line_item_quantity,
        coalesce(order_line_refunds.price_shop_amount, 0) as price_shop_amount,
        coalesce(order_line_refunds.subtotal_shop_amount, 0) as subtotal_shop_amount,
        coalesce(order_line_refunds.total_tax_shop_amount, 0) as total_tax_shop_amount,
        coalesce(order_line_refunds.subtotal_shop_amount, 0) + coalesce(order_line_refunds.total_tax_shop_amount, 0) as total_refunded_line_shop_amount,

        -- refund line financials (presentment currency)
        coalesce(order_line_refunds.price_pres_amount, 0) as price_pres_amount,
        order_line_refunds.price_pres_currency_code,
        coalesce(order_line_refunds.subtotal_pres_amount, 0) as subtotal_pres_amount,
        order_line_refunds.subtotal_pres_currency_code,
        coalesce(order_line_refunds.total_tax_pres_amount, 0) as total_tax_pres_amount,
        order_line_refunds.total_tax_pres_currency_code,
        coalesce(order_line_refunds.subtotal_pres_amount, 0) + coalesce(order_line_refunds.total_tax_pres_amount, 0) as total_refunded_line_pres_amount,

        -- inventory / restock classification
        order_line_refunds.restock_type,
        order_line_refunds.location_id as restock_location_id,
        order_line_refunds.restock_type in ('return', 'cancel', 'legacy_restock') as is_restocked,
        (coalesce(order_line_refunds.subtotal_shop_amount, 0) = 0
            and coalesce(order_line_refunds.total_tax_shop_amount, 0) = 0
            and order_line_refunds.restock_type in ('return', 'cancel', 'legacy_restock')) as is_restock_only,

        -- refund-level discrepancy adjustment (shop and presentment)
        order_adjustment_aggregates.refund_discrepancy_shop_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_shop_amount,
        order_adjustment_aggregates.refund_discrepancy_pres_amount,
        order_adjustment_aggregates.refund_discrepancy_tax_pres_amount,

        refunds.source_relation

    from order_line_refunds
    join refunds
        on order_line_refunds.refund_id = refunds.refund_id
        and order_line_refunds.source_relation = refunds.source_relation
    left join order_lines
        on order_line_refunds.order_line_id = order_lines.order_line_id
        and order_line_refunds.source_relation = order_lines.source_relation
    left join orders
        on refunds.order_id = orders.order_id
        and refunds.source_relation = orders.source_relation
    left join order_adjustment_aggregates
        on refunds.refund_id = order_adjustment_aggregates.refund_id
        and refunds.source_relation = order_adjustment_aggregates.source_relation
    {% if var('shopify_gql_using_return', False) %}
    left join returns
        on refunds.return_id = returns.return_id
        and refunds.source_relation = returns.source_relation
    left join return_line_items
        on refunds.return_id = return_line_items.return_id
        and order_line_refunds.order_line_id = return_line_items.order_line_id
        and order_line_refunds.source_relation = return_line_items.source_relation
    left join return_shipping_fee_aggregates
        on refunds.return_id = return_shipping_fee_aggregates.return_id
        and refunds.source_relation = return_shipping_fee_aggregates.source_relation
    {% endif %}

)

select *
from joined
