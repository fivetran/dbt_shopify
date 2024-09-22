SELECT
    DATE_TRUNC(shopify__orders.created_timestamp, DAY) AS order_date,
    shopify__orders.billing_address_country,
    shopify__orders.total_price AS gross_sale_amount,
    shopify__orders.refund_subtotal,
    shopify__orders.total_price - shopify__orders.refund_subtotal AS subtotal_sold_refunds,
    shopify__orders.total_price - shopify__orders.total_discounts - shopify__orders.refund_subtotal AS net_sale_price,
    shopify__orders.shipping_cost AS shipping_price,
    shopify__orders.total_price + shopify__orders.shipping_cost + shopify__orders.total_tax AS total_sale_price
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders;