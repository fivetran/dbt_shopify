SELECT
    DATE_TRUNC(`order`.created_at, DAY) AS order_date,
    customer_visit.referrer_url AS referring_channel,
    customer_visit.source AS referring_category,
   `order`.total_price AS order_value
  FROM
    smartycommerce.shopify_fivetran.order AS `order`
    INNER JOIN smartycommerce.shopify_fivetran.customer_visit AS customer_visit ON `order`.id = customer_visit.order_id