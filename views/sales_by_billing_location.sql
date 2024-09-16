SELECT
    shopify__orders.billing_address_country,
    count(shopify__orders.order_id) AS number_of_orders,
    sum(shopify__orders.total_price) AS gross_sales,
    sum(shopify__orders.total_discounts) AS discounts,
    sum(shopify__orders.refund_subtotal) AS returns,
    sum(shopify__orders.total_price) - sum(shopify__orders.total_discounts) - sum(shopify__orders.refund_subtotal) AS net_sales,
    sum(shopify__orders.shipping_cost) AS shipping,
    sum(shopify__orders.total_tax) AS taxes,
    sum(shopify__orders.total_price) + sum(shopify__orders.shipping_cost) + sum(shopify__orders.total_tax) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
  GROUP BY 1;
