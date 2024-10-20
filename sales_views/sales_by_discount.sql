SELECT
    shopify__discounts.code AS discount_name,
    shopify__discounts.allocation_method AS discount_method,
    shopify__discounts.value_type AS discount_type,
    shopify__discounts.target_type AS discount_class,
    count(shopify__orders.order_id) AS number_of_orders,
    sum(shopify__orders.total_price) AS total_gross_sales,
    sum(shopify__orders.total_discounts) AS total_discount_amount,
    sum(shopify__orders.refund_subtotal) AS total_returns,
    sum(shopify__orders.order_adjusted_total) AS total_net_sales,
    sum(shopify__orders.shipping_cost) AS total_shipping_price,
    sum(shopify__orders.total_tax) AS total_tax_amount,
    sum(shopify__orders.total_price) AS grand_total_sales
  FROM
    `smartycommerce.shopify_fivetran_shopify.shopify__discounts` AS shopify__discounts
    LEFT JOIN `smartycommerce.shopify_fivetran_shopify.shopify__orders` AS shopify__orders ON shopify__discounts.discount_code_id = shopify__orders.order_id
  GROUP BY 1, 2, 3, 4;
