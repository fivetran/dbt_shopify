SELECT
    customer_visit.source,
    DATE_TRUNC(transactions.created_timestamp, YEAR) AS month,
    sum(transactions.amount) AS total_amount
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__transactions` AS transactions
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders ON transactions.order_id = orders.order_id
    INNER JOIN `smartycommerce.shopify_fivetran.customer_visit` AS customer_visit ON orders.order_id = customer_visit.order_id
  GROUP BY 1, 2
ORDER BY
  month;