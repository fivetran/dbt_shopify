{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with customer_emails as (

    select 
        {{ dbt_utils.star(from=ref('int_shopify_gql__customer_email_rollup'), except=["orders_count", "total_spent", "unique_key"]) }}
    from {{ ref('int_shopify_gql__customer_email_rollup') }}

), orders as (

    select *
    from {{ ref('int_shopify_gql__emails_order_aggregates' )}}
    where email is not null

{% if var('shopify_gql_using_abandoned_checkout', True) %}
), abandoned as (

    select 
        lower(email) as email,
        source_relation,
        count(distinct checkout_id) as lifetime_abandoned_checkouts
    from {{ ref('int_shopify_gql__abandoned_checkout' )}}
    where email is not null
    group by 1,2
{% endif %}

), joined as (

    select 
        customer_emails.*, -- contains customer metafields

        {% if var('shopify_gql_using_abandoned_checkout', True) %}
        coalesce(abandoned.lifetime_abandoned_checkouts, 0) as lifetime_abandoned_checkouts,
        {% endif %}

        orders.first_order_timestamp,
        orders.most_recent_order_timestamp,
        orders.avg_order_value,
        coalesce(orders.lifetime_total_spent, 0) as lifetime_total_spent,
        coalesce(orders.lifetime_total_refunded, 0) as lifetime_total_refunded,
        (coalesce(orders.lifetime_total_spent, 0) - coalesce(orders.lifetime_total_refunded, 0)) as lifetime_total_net,
        coalesce(orders.lifetime_count_orders, 0) as lifetime_count_orders,
        orders.avg_quantity_per_order,
        coalesce(orders.lifetime_total_tax, 0) as lifetime_total_tax,
        orders.avg_tax_per_order,
        coalesce(orders.lifetime_total_discount, 0) as lifetime_total_discount,
        orders.avg_discount_per_order,
        coalesce(orders.lifetime_total_shipping, 0) as lifetime_total_shipping,
        orders.avg_shipping_per_order,
        coalesce(orders.lifetime_total_shipping_with_discounts, 0) as lifetime_total_shipping_with_discounts,
        orders.avg_shipping_with_discounts_per_order,
        coalesce(orders.lifetime_total_shipping_tax, 0) as lifetime_total_shipping_tax,
        orders.avg_shipping_tax_per_order

    from customer_emails
    left join orders
        on customer_emails.email = orders.email
        and customer_emails.source_relation = orders.source_relation

    {% if var('shopify_gql_using_abandoned_checkout', True) %}
    left join abandoned
        on customer_emails.email = abandoned.email
        and customer_emails.source_relation = abandoned.source_relation
    {% endif %}
)

select *
from joined