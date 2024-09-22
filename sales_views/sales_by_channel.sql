SELECT
    shopify__orders.source_name,
    DATE_TRUNC(shopify__orders.created_timestamp, DAY) AS order_date,
    shopify__orders.total_price AS gross_sale_amount,
    shopify__orders.total_discounts AS discount_amount,
    shopify__transactions.amount AS transaction_amount,
    shopify__orders.total_price - shopify__orders.total_discounts AS net_sale_amount,
    shopify__orders.shipping_cost AS shipping_cost,
    shopify__orders.total_price + shopify__orders.shipping_cost AS total_sale_amount
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__transactions` AS shopify__transactions ON shopify__orders.order_id = shopify__transactions.order_id;