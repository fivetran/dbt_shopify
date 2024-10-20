SELECT
    DATE_TRUNC(`order`.created_at, YEAR) AS order_date,
    `order`.shipping_address_country AS country,
    `order`.shipping_address_province AS region,
    `order`.shipping_address_city AS city,
    count(DISTINCT `order`.customer_id) AS num_visitors,
    count(customer_visit.id) AS num_sessions
  FROM
    smartycommerce.shopify_fivetran.order AS `order`
    INNER JOIN smartycommerce.shopify_fivetran.customer_visit AS customer_visit ON `order`.id = customer_visit.order_id
  GROUP BY 1, 2, 3,4
 -- ORDER BY order_date;