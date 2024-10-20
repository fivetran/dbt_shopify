SELECT
    DATE_TRUNC(`order`.created_at, DAY) AS order_date,
    CASE
      WHEN shopify__customers.lifetime_count_orders = 1 THEN 'First-time'
      ELSE 'Returning'
    END AS customer_type,
    count(DISTINCT shopify__customers.customer_id) AS customer_count
  FROM
    smartycommerce.shopify_fivetran_shopify.shopify__orders AS shopify__orders
    INNER JOIN smartycommerce.shopify_fivetran_shopify.shopify__customers AS shopify__customers ON shopify__orders.customer_id = shopify__customers.customer_id
    INNER JOIN smartycommerce.shopify_fivetran.order AS `order` ON shopify__orders.order_id = `order`.id
  GROUP BY 1, 2