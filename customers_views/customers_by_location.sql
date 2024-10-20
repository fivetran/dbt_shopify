SELECT
    DATE_TRUNC(`order`.created_at, DAY) AS order_date,
    `order`.billing_address_country,
    `order`.billing_address_province,
    `order`.billing_address_city,
    `order`.total_price
  FROM
    smartycommerce.shopify_fivetran.order AS `order`