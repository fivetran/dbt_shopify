SELECT
    shopify__orders.source_name,
    count(shopify__orders.order_id) AS num_orders,
    sum(shopify__orders.total_price) AS gross_sales,
    sum(shopify__orders.total_discounts) AS discounts,
    sum(shopify__transactions.amount) AS returns,
    sum(shopify__orders.total_price) - sum(shopify__transactions.amount) AS net_sales,
    sum(shopify__orders.shipping_cost) AS shipping,
    sum(shopify__orders.total_tax) AS taxes,
    sum(shopify__orders.total_price) + sum(shopify__orders.shipping_cost) + sum(shopify__orders.total_tax) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__transactions` AS shopify__transactions ON shopify__orders.order_id = shopify__transactions.order_id
  GROUP BY 1;
