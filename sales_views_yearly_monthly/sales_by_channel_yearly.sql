SELECT
    shopify__orders.source_name,
    DATE_TRUNC(shopify__orders.created_timestamp, YEAR) AS order_date,
    sum(shopify__orders.total_price) AS gross_sale_amount,
    sum(shopify__orders.total_discounts) AS discount_amount,
    sum(shopify__transactions.amount) AS transaction_amount,
    sum(shopify__orders.total_price - shopify__orders.total_discounts) AS net_sale_amount,
    sum(shopify__orders.shipping_cost) AS shipping_cost,
    sum(shopify__orders.total_price + shopify__orders.shipping_cost) AS total_sale_amount
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__transactions` AS shopify__transactions ON shopify__orders.order_id = shopify__transactions.order_id
  GROUP BY 1, 2;