SELECT
    DATE_TRUNC(shopify__orders.created_timestamp, DAY) AS order_date,
    shopify__products.title AS product_title,
    shopify__inventory_levels.variant_title AS variant_title,
    shopify__inventory_levels.subtotal_sold_refunds,
    shopify__inventory_levels.sku,
    shopify__inventory_levels.cost
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders
    INNER JOIN `smartycommerce.shopify_fivetran.order` AS orderr ON shopify__orders.order_id = orderr.id
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS shopify__inventory_levels ON orderr.location_id = shopify__inventory_levels.location_id
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__products` AS shopify__products ON shopify__inventory_levels.product_id = shopify__products.product_id