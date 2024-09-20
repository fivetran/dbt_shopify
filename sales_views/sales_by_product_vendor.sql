SELECT
    products.vendor,
    sum(inventory_levels.net_quantity_sold) AS net_quantity,
    sum(inventory_levels.subtotal_sold) AS gross_sales,
    sum(orders__order_line_aggregates.order_total_discount) AS discounts,
    sum(orders__order_line_aggregates.order_total_quantity) AS returns,
    sum(inventory_levels.net_subtotal_sold) AS net_sales,
    sum(orders__order_line_aggregates.order_total_tax) AS taxes,
    sum(orders.total_price) AS total_sales
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__products` AS products
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__inventory_levels` AS inventory_levels ON products.product_id = inventory_levels.product_id
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS orders ON inventory_levels.product_id = orders.order_id
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders__order_line_aggregates` AS orders__order_line_aggregates ON orders.order_id = orders__order_line_aggregates.order_id
  GROUP BY 1;
