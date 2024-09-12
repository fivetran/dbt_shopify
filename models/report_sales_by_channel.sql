with sales_by_channel as (

    select 
        orders.source_name AS api_client_title,
        count(orders.order_id) AS orders,
        sum(orders.total_price) AS gross_sales,
        sum(orders.total_discounts) AS discounts,
        sum(orders.refund_subtotal) AS returns,
        sum(orders.order_adjusted_total) AS net_sales,
        sum(orders.shipping_cost) AS shipping,
        sum(orders.total_tax) AS taxes,
        sum(orders.total_price) AS total_sales
    from 
        {{ ref('shopify__orders') }} as orders
    GROUP BY 1

)

select *
from sales_by_channel