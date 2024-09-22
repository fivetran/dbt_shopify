SELECT
    customer.first_name || ' ' || customer.last_name AS customer_name,
    customer.email,
    DATE_TRUNC(shopify__orders.created_timestamp, MONTH) AS order_month,
    count(shopify__orders.order_id) AS orders,
    sum(shopify__orders.total_price) AS gross_sales,
    sum(shopify__orders.total_price - shopify__orders.total_tax) AS net_sales,
    sum(shopify__orders.total_price) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran.customer` AS customer
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders ON customer.id = shopify__orders.customer_id
  GROUP BY 1, 2, 3;

  