SELECT
    DATE_TRUNC(`order`.created_at, DAY) AS order_date,
    customer_visit.referrer_url AS referring_channel,
    customer_visit.source AS referring_category,
    count(DISTINCT `order`.id) AS num_orders,
    count(DISTINCT `order`.customer_id) AS num_visitors,
    count(customer_visit.id) AS num_sessions,
  FROM
    smartycommerce.shopify_fivetran.order AS `order`
    INNER JOIN smartycommerce.shopify_fivetran.customer_visit AS customer_visit ON `order`.id = customer_visit.order_id
  GROUP BY 1, 2, 3