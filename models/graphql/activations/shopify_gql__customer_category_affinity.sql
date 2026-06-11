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
        lifetime_count_orders,
        lifetime_total_net,
        avg_order_value,
        most_recent_order_timestamp,
        first_order_timestamp
    from {{ ref('shopify_gql__customers') }}
    where email is not null
        and lifetime_count_orders > 0

), orders as (

    select
        order_id,
        customer_id,
        source_relation,
        created_timestamp as order_created_at
    from {{ ref('shopify_gql__orders') }}
    where customer_id is not null

), order_lines as (

    select
        order_id,
        source_relation,
        product_id,
        title       as product_title,
        vendor,
        quantity,
        price_shop_amount as line_price
    from {{ ref('shopify_gql__order_lines') }}
    where product_id is not null

), products as (

    select
        product_id,
        source_relation,
        product_type,
        title as product_name
    from {{ ref('shopify_gql__products') }}

), customer_lines as (

    -- flatten to one row per customer × order line, enriched with product_type
    select
        customers.customer_id,
        customers.source_relation,
        customers.email,
        orders.order_id,
        orders.order_created_at,
        order_lines.product_id,
        order_lines.product_title,
        order_lines.vendor,
        order_lines.quantity,
        order_lines.line_price,
        coalesce(nullif(trim(products.product_type), ''), 'uncategorized') as product_type
    from customers
    inner join orders
        on customers.customer_id = orders.customer_id
        and customers.source_relation = orders.source_relation
    inner join order_lines
        on orders.order_id = order_lines.order_id
        and orders.source_relation = order_lines.source_relation
    left join products
        on order_lines.product_id = products.product_id
        and order_lines.source_relation = products.source_relation

), last_purchase as (

    -- most recent product type per customer for recency signal
    select
        customer_id,
        source_relation,
        product_type as last_purchased_product_type,
        product_title as last_purchased_product_title,
        vendor as last_purchased_vendor
    from (
        select
            customer_id,
            source_relation,
            product_type,
            product_title,
            vendor,
            row_number() over (
                partition by customer_id, source_relation
                order by order_created_at desc
            ) as recency_rank
        from customer_lines
    ) ranked
    where recency_rank = 1

), top_category as (

    -- product type with the most distinct orders per customer
    select
        customer_id,
        source_relation,
        product_type as top_product_type
    from (
        select
            customer_id,
            source_relation,
            product_type,
            count(distinct order_id) as type_order_count,
            row_number() over (
                partition by customer_id, source_relation
                order by count(distinct order_id) desc
            ) as type_rank
        from customer_lines
        group by 1, 2, 3
    ) ranked
    where type_rank = 1

), aggregated as (

    select
        customer_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(product_type as " ~ dbt.type_string() ~ ")", "', '") }} as purchased_product_types,
        {{ fivetran_utils.string_agg("distinct cast(vendor as " ~ dbt.type_string() ~ ")", "', '") }} as purchased_vendors,
        {{ fivetran_utils.string_agg("distinct cast(product_title as " ~ dbt.type_string() ~ ")", "', '") }} as purchased_product_titles,
        count(distinct product_type) as total_distinct_product_types,
        count(distinct vendor) as total_distinct_vendors,
        count(distinct order_id) as total_orders,
        sum(quantity) as total_units_purchased,
        sum(line_price) as total_gross_revenue
    from customer_lines
    group by 1, 2

), final as (

    select
        -- identity
        customers.email,
        customers.first_name,
        customers.last_name,
        customers.phone,

        -- category affinity (primary fields for "bought A, not B" filtering)
        aggregated.purchased_product_types,
        aggregated.purchased_vendors,
        aggregated.total_distinct_product_types,
        aggregated.total_distinct_vendors,
        top_category.top_product_type,
        last_purchase.last_purchased_product_type,
        last_purchase.last_purchased_vendor,

        -- purchase depth
        aggregated.total_orders,
        aggregated.total_units_purchased,
        aggregated.total_gross_revenue,
        customers.lifetime_total_net,
        customers.avg_order_value,
        customers.lifetime_count_orders,

        -- recency
        customers.most_recent_order_timestamp,
        customers.first_order_timestamp,
        {{ dbt.datediff('customers.most_recent_order_timestamp', dbt.current_timestamp(), 'day') }} as days_since_last_purchase,

        -- metadata
        customers.customer_id,
        customers.source_relation

    from customers
    left join aggregated
        on customers.customer_id = aggregated.customer_id
        and customers.source_relation = aggregated.source_relation
    left join top_category
        on customers.customer_id = top_category.customer_id
        and customers.source_relation = top_category.source_relation
    left join last_purchase
        on customers.customer_id = last_purchase.customer_id
        and customers.source_relation = last_purchase.source_relation

)

select *
from final
