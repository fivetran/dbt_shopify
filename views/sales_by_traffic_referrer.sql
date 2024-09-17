SELECT
    customer_visit.source,
    count(customer_visit.order_id) AS num_orders,
    sum(customer_visit.order_id) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran.customer_visit` AS customer_visit
  GROUP BY 1;