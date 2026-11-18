{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

with order_lines as (

    select *
    from {{ ref('stg_shopify__order_line') }}
),

fulfillment as (

    select *
    from {{ ref('stg_shopify__fulfillment') }}
),

orders as (

    select *
    from {{ ref('stg_shopify__order') }}
    where not coalesce(is_deleted, false)
),

refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), refunds_aggregated as (

    select
        order_line_id,
        source_relation,
        sum(quantity) as quantity,
        sum(coalesce(subtotal, 0)) as subtotal

    from refunds
    group by 1,2
),

{% if var('shopify_using_fulfillment_order_line', true) %}
fulfillment_order_line as (

    select *
    from {{ ref('stg_shopify__fulfillment_order_line') }}
),

-- one row per order line per fulfillment that contains it
line_fulfillments as (

    select
        fulfillment_order_line.order_line_id,
        fulfillment_order_line.source_relation,
        fulfillment.fulfillment_id,
        fulfillment.location_id, -- location id is stored in fulfillment rather than order
        fulfillment.status as fulfillment_status,
        fulfillment_order_line.quantity as fulfilled_quantity

    from fulfillment_order_line
    join fulfillment
        on fulfillment_order_line.fulfillment_id = fulfillment.fulfillment_id
        and fulfillment_order_line.source_relation = fulfillment.source_relation
),

{% else %}
-- without fulfillment_order_line, every fulfillment on the order is linked to every line on the order
line_fulfillments as (

    select
        order_lines.order_line_id,
        order_lines.source_relation,
        fulfillment.fulfillment_id,
        fulfillment.location_id, -- location id is stored in fulfillment rather than order
        fulfillment.status as fulfillment_status,
        cast(null as {{ dbt.type_int() }}) as fulfilled_quantity

    from order_lines
    join fulfillment
        on order_lines.order_id = fulfillment.order_id
        and order_lines.source_relation = fulfillment.source_relation
),

{% endif %}
joined as (

    select
        order_lines.order_line_id,
        order_lines.variant_id,
        order_lines.source_relation,
        line_fulfillments.location_id,
        orders.order_id,
        orders.customer_id,
        line_fulfillments.fulfillment_id,
        lower(orders.email) as email,
        order_lines.pre_tax_price,
        order_lines.quantity,
        orders.created_timestamp as order_created_timestamp,
        line_fulfillments.fulfillment_status,
        line_fulfillments.fulfilled_quantity,
        coalesce(line_fulfillments.fulfillment_status, '') not in ('cancelled', 'error', 'failure') as is_fulfilled

    from order_lines
    join orders
        on order_lines.order_id = orders.order_id
        and order_lines.source_relation = orders.source_relation
    join line_fulfillments
        on order_lines.order_line_id = line_fulfillments.order_line_id
        and order_lines.source_relation = line_fulfillments.source_relation
),

-- one row per order line per location, so each line counts once per location
line_locations as (

    select
        order_line_id,
        variant_id,
        location_id,
        source_relation,
        order_id,
        customer_id,
        email,
        order_created_timestamp,
        pre_tax_price,
        quantity,

        {% if var('shopify_using_fulfillment_order_line', true) %}
        -- only the units this location shipped, excluding cancelled, errored, and failed fulfillments
        sum(case when is_fulfilled then coalesce(fulfilled_quantity, 0) else 0 end) as quantity_sold
        {% else %}
        max(quantity) as quantity_sold
        {% endif %}

    from joined
    {{ dbt_utils.group_by(n=10) }}
),

allocated as (

    select
        line_locations.*,

        {% if var('shopify_using_fulfillment_order_line', true) %}
        -- share of the order line shipped from this location, used to split the line's amounts across locations
        coalesce(cast(line_locations.quantity_sold as {{ dbt.type_float() }}) / nullif(line_locations.quantity, 0), 0) as location_share,
        {% else %}
        1 as location_share,
        {% endif %}

        refunds_aggregated.subtotal as subtotal_sold_refunds,
        refunds_aggregated.quantity as quantity_sold_refunds

    from line_locations
    left join refunds_aggregated
        on refunds_aggregated.order_line_id = line_locations.order_line_id
        and refunds_aggregated.source_relation = line_locations.source_relation
),

line_location_aggregated as (

    select
        variant_id,
        location_id,
        source_relation,
        sum(pre_tax_price * location_share) as subtotal_sold,
        sum(quantity_sold) as quantity_sold,
        count(distinct order_id) as count_distinct_orders,
        count(distinct customer_id) as count_distinct_customers,
        count(distinct email) as count_distinct_customer_emails,
        min(order_created_timestamp) as first_order_timestamp,
        max(order_created_timestamp) as last_order_timestamp,
        sum(coalesce(subtotal_sold_refunds, 0) * location_share) as subtotal_sold_refunds,
        sum(coalesce(quantity_sold_refunds, 0) * location_share) as quantity_sold_refunds

    from allocated
    {{ dbt_utils.group_by(n=3) }}
),

fulfillment_status_aggregated as (

    select
        variant_id,
        location_id,
        source_relation

        {% for status in ['pending', 'open', 'success', 'cancelled', 'error', 'failure'] %}
        , count(distinct case when fulfillment_status = '{{ status }}' then fulfillment_id end) as count_fulfillment_{{ status }}
        {% endfor %}

    from joined
    {{ dbt_utils.group_by(n=3) }}
),

aggregated as (

    select
        line_location_aggregated.variant_id,
        line_location_aggregated.location_id,
        line_location_aggregated.source_relation,
        line_location_aggregated.subtotal_sold,
        line_location_aggregated.quantity_sold,
        line_location_aggregated.count_distinct_orders,
        line_location_aggregated.count_distinct_customers,
        line_location_aggregated.count_distinct_customer_emails,
        line_location_aggregated.first_order_timestamp,
        line_location_aggregated.last_order_timestamp

        {% for status in ['pending', 'open', 'success', 'cancelled', 'error', 'failure'] %}
        , fulfillment_status_aggregated.count_fulfillment_{{ status }}
        {% endfor %}

        , line_location_aggregated.subtotal_sold_refunds
        , line_location_aggregated.quantity_sold_refunds

    from line_location_aggregated
    join fulfillment_status_aggregated
        on line_location_aggregated.variant_id = fulfillment_status_aggregated.variant_id
        and line_location_aggregated.location_id = fulfillment_status_aggregated.location_id
        and line_location_aggregated.source_relation = fulfillment_status_aggregated.source_relation
)

select *
from aggregated