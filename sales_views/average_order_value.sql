SELECT
    DATE(orders.created_timestamp) AS day,
    SUM(orders.total_price) AS gross_sales,
    SUM(orders.total_discounts) AS total_discounts,
    COUNT(DISTINCT orders.order_id) AS number_of_orders,
    (
      SUM(orders.total_price) - SUM(orders.total_discounts)
    ) / COUNT(DISTINCT orders.order_id) AS average_order_value
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders
  GROUP BY 1;
