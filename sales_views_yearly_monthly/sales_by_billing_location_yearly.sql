SELECT
    DATE_TRUNC(shopify__orders.created_timestamp, YEAR) AS order_date,
    shopify__orders.billing_address_country,
    SUM(shopify__orders.total_price) AS gross_sale_amount,
    SUM(shopify__orders.refund_subtotal) AS refund_subtotal,
    SUM(shopify__orders.total_price - shopify__orders.refund_subtotal) AS subtotal_sold_refunds,
    SUM(shopify__orders.total_price - shopify__orders.total_discounts - shopify__orders.refund_subtotal) AS net_sale_price,
    SUM(shopify__orders.shipping_cost) AS shipping_price,
    SUM(shopify__orders.total_price + shopify__orders.shipping_cost + shopify__orders.total_tax) AS total_sale_price
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
  GROUP BY 1, 2;