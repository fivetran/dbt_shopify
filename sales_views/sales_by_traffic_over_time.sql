SELECT
    transactions.created_timestamp,
    transactions.amount,
    customer_visit.source
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__transactions` AS transactions
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders ON transactions.order_id = orders.order_id
    INNER JOIN `smartycommerce.shopify_fivetran.customer_visit` AS customer_visit ON orders.order_id = customer_visit.order_id
ORDER BY
  transactions.created_timestamp;