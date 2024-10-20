SELECT
    DATE_TRUNC(shopify__inventory_levels.first_order_timestamp, DAY) AS order_date,
    shopify__products.title AS product_title,
    shopify__products.product_type AS product_type,
    shopify__products.vendor AS vendor,
    shopify__inventory_levels.net_quantity_sold,
    shopify__inventory_levels.cost,
    shopify__inventory_levels.subtotal_sold_refunds - shopify__inventory_levels.cost AS gross_margin,
    SAFE_DIVIDE(shopify__inventory_levels.subtotal_sold_refunds - shopify__inventory_levels.cost, shopify__inventory_levels.subtotal_sold_refunds) AS gross_profit
FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS shopify__inventory_levels
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__products` AS shopify__products 
    ON shopify__inventory_levels.product_id = shopify__products.product_id;