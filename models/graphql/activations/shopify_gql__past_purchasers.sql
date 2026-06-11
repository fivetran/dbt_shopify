{{ config(
    enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql'),
    materialized='table'
) }}

with customers as (

    select
        customer_id,
        source_relation,
        email,
        first_name,
        last_name,
        phone,
        default_address_city,
        default_address_country,
        default_address_country_code,
        default_address_province,
        default_address_zip,
        account_state,
        customer_tags,
        first_order_timestamp,
        most_recent_order_timestamp,
        lifetime_count_orders,
        lifetime_total_spent,
        lifetime_total_refunded,
        lifetime_total_net,
        avg_order_value,
        lifetime_total_discount,
        lifetime_abandoned_checkouts
    from {{ ref('shopify_gql__customers') }}
    where email is not null

), orders as (

    select
        customer_id,
        source_relation,
        order_id,
        name as order_name,
        created_timestamp as order_created_at,
        total_price_shop_amount as order_total,
        financial_status,
        fulfillment_status,
        new_vs_repeat
    from {{ ref('shopify_gql__orders') }}
    where customer_id is not null

), orders_agg as (

    select
        customer_id,
        source_relation,
        count(distinct order_id) as total_orders,
        max(order_created_at) as last_purchase_at,
        min(order_created_at) as first_purchase_at,
        {{ dbt.datediff("max(order_created_at)", dbt.current_timestamp(), 'day') }} as days_since_last_purchase,
        {{ fivetran_utils.string_agg("distinct cast(order_name as " ~ dbt.type_string() ~ ")", "', '") }} as order_names
    from orders
    group by 1, 2

), final as (

    select
        -- identity
        customers.email,
        customers.first_name,
        customers.last_name,
        customers.phone,

        -- location
        customers.default_address_city,
        customers.default_address_country,
        customers.default_address_country_code,
        customers.default_address_province,
        customers.default_address_zip,

        -- purchase behavior
        customers.first_order_timestamp,
        customers.most_recent_order_timestamp,
        orders_agg.days_since_last_purchase,
        customers.lifetime_count_orders,
        customers.lifetime_total_spent,
        customers.lifetime_total_refunded,
        customers.lifetime_total_net,
        customers.avg_order_value,
        customers.lifetime_total_discount,

        -- segmentation helpers
        customers.account_state,
        customers.customer_tags,
        orders_agg.order_names,

        {% if var('shopify_gql_using_abandoned_checkout', True) %}
        customers.lifetime_abandoned_checkouts,
        {% endif %}

        -- metadata
        customers.customer_id,
        customers.source_relation

    from customers
    left join orders_agg
        on customers.customer_id = orders_agg.customer_id
        and customers.source_relation = orders_agg.source_relation

)

select *
from final
