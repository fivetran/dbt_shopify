with order_lines as (

    select *
    from {{ ref('shopify__order_lines') }}

), orders as (

    select *
    from {{ ref('shopify__orders') }}
    
), fields as (

    select
        {{ dbt_utils.surrogate_key(['order_lines.order_line_id',"'product_purchased'"]) }} as event_id,
        orders.created_timestamp as event_timestamp,
        orders.customer_email,
        'product_purchased' as event_type,
        order_lines.price as revenue_impact,
        order_lines.sku as feature_1,
        order_lines.name as feature_2,
        cast(order_lines.quantity as {{ dbt_utils.type_string() }}) as feature_3,
        'shopify' as source,
        orders.customer_id as source_id,
        cast(null as {{ dbt_utils.type_string() }}) as link
    from orders
    inner join order_lines
        on orders.order_id = order_lines.order_id
    where orders.created_timestamp is not null

)

select *
from fields