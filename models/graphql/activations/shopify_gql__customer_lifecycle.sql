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
        marketing_consent_state,
        customer_tags,
        first_order_timestamp,
        most_recent_order_timestamp,
        lifetime_count_orders,
        lifetime_total_net,
        lifetime_total_spent,
        lifetime_total_refunded,
        avg_order_value,
        lifetime_total_discount,
        {% if var('shopify_gql_using_abandoned_checkout', True) %}
        lifetime_abandoned_checkouts,
        {% endif %}
        created_timestamp as customer_created_at
    from {{ ref('shopify_gql__customers') }}
    where email is not null
        and lifetime_count_orders > 0

), staged as (

    select
        *,
        {{ dbt.datediff('most_recent_order_timestamp', dbt.current_timestamp(), 'day') }} as days_since_last_purchase,
        {{ dbt.datediff('first_order_timestamp', dbt.current_timestamp(), 'day') }}       as days_since_first_purchase,

        case
            when (lifetime_total_net >= 500 or lifetime_count_orders >= 5)
                and {{ dbt.datediff('most_recent_order_timestamp', dbt.current_timestamp(), 'day') }} <= 180
                then 'vip'
            when lifetime_count_orders = 1
                and {{ dbt.datediff('most_recent_order_timestamp', dbt.current_timestamp(), 'day') }} <= 30
                then 'new'
            when {{ dbt.datediff('most_recent_order_timestamp', dbt.current_timestamp(), 'day') }} <= 90
                then 'active'
            else 'lapsed'
        end as customer_stage

    from customers

)

select
    -- identity
    email,
    first_name,
    last_name,
    phone,

    -- lifecycle
    customer_stage,
    days_since_last_purchase,
    days_since_first_purchase,
    first_order_timestamp,
    most_recent_order_timestamp,

    -- value signals
    lifetime_count_orders,
    lifetime_total_net,
    avg_order_value,
    lifetime_total_discount,

    {% if var('shopify_gql_using_abandoned_checkout', True) %}
    lifetime_abandoned_checkouts,
    {% endif %}

    -- marketing flags
    marketing_consent_state,
    customer_tags,

    -- metadata
    customer_created_at,
    customer_id,
    source_relation

from staged
