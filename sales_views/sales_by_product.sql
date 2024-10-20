SELECT
    shopify__products.title,
    shopify__products.product_type,
    shopify__products.vendor,
    DATE_TRUNC(shopify__inventory_levels.last_order_timestamp, MONTH) AS order_month,  
    SUM(shopify__inventory_levels.net_quantity_sold) AS total_quantity_sold,
    SUM(shopify__inventory_levels.net_subtotal_sold) AS total_sales,
    SUM(shopify__inventory_levels.cost) AS total_cost,
    SUM(shopify__inventory_levels.net_subtotal_sold - shopify__inventory_levels.cost) AS gross_profit,
    SUM(shopify__products.product_total_discount) AS total_discount,
    SUM(shopify__inventory_levels.quantity_sold_refunds) AS total_returns
FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__products` AS shopify__products
INNER JOIN
    `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS shopify__inventory_levels
    ON shopify__products.product_id = shopify__inventory_levels.product_id
GROUP BY
    order_month, shopify__products.title, shopify__products.product_type, shopify__products.vendor
ORDER BY
    order_month;