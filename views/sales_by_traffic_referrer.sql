SELECT
    shopify__orders.referring_site,
    shopify__orders.name,
    count(shopify__orders.order_id) AS num_orders,
    sum(shopify__orders.total_price) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
  GROUP BY 1, 2;
