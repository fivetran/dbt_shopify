with order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders') }}

), refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}
    
), fields as (

    select
        {{ dbt_utils.surrogate_key(['order_lines.order_line_id',"'product_refunded'"]) }} as event_id,
        refunds.created_at as event_timestamp,
        orders.customer_email,
        'product_refunded' as event_type,
        refunds.subtotal * -1.0 as revenue_impact,
        order_lines.sku as feature_1,
        order_lines.name as feature_2,
        cast(refunds.quantity as {{ dbt_utils.type_string() }}) as feature_3,
        'shopify' as source,
        orders.customer_id as source_id,
        cast(null as {{ dbt_utils.type_string() }}) as link
    from orders
    inner join order_lines
        on orders.order_id = order_lines.order_id
    inner join refunds
        on order_lines.order_line_id = refunds.order_line_id
    where refunds.created_at is not null

)

select *
from fields