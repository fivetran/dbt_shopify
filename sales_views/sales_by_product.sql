SELECT
    shopify__products.title,
    shopify__products.vendor,
    shopify__products.product_type,
    shopify__inventory_levels.net_quantity_sold,
    shopify__inventory_levels.subtotal_sold,
    shopify__products.product_total_discount,
    shopify__inventory_levels.quantity_sold_refunds,
    shopify__inventory_levels.net_subtotal_sold,
    shopify__products.product_total_tax,
    shopify__orders.total_price
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__products` AS shopify__products
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS shopify__inventory_levels ON shopify__products.product_id = shopify__inventory_levels.product_id
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders ON shopify__inventory_levels.product_id = shopify__orders.order_id;

