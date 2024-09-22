SELECT
    products.vendor,
    products.title,
    DATE_TRUNC(orders.created_timestamp, DAY) AS created_date,
    inventory_levels.net_quantity_sold,
    inventory_levels.subtotal_sold_refunds,
    orders.total_discounts,
    orders.total_tax,
    orders.total_price
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__products` AS products
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS inventory_levels ON products.product_id = inventory_levels.product_id
    INNER JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders ON inventory_levels.location_id = orders.location_id;