SELECT
    products.title AS product_title,
    inventory_levels.variant_title,
    inventory_levels.sku,
    inventory_levels.net_quantity_sold,
    inventory_levels.subtotal_sold,
    orders__order_line_aggregates.order_total_discount,
    inventory_levels.quantity_sold_refunds,
    inventory_levels.net_subtotal_sold,
    orders__order_line_aggregates.order_total_tax,
    orders.total_price
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__products` AS products
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS inventory_levels ON products.product_id = inventory_levels.product_id
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders ON inventory_levels.product_id = orders.order_id
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders__order_line_aggregates` AS orders__order_line_aggregates ON orders.order_id = orders__order_line_aggregates.order_id;

--still needs to be enhanced--