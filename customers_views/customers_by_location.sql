SELECT
    shopify__orders.billing_address_country,
    shopify__orders.billing_address_province,
    shopify__orders.billing_address_city,
    count(DISTINCT shopify__customers.customer_id) AS total_customers,
    count(DISTINCT shopify__orders.order_id) AS total_orders,
    sum(shopify__orders.total_price) AS total_amount_spent
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__customers` AS shopify__customers ON shopify__orders.customer_id = shopify__customers.customer_id
  GROUP BY 1, 2, 3;