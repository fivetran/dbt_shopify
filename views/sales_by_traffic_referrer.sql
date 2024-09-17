SELECT
    customer_visit.source,
    COUNT(o_rder.id) AS num_orders,
    SUM(o_rder.total_price) AS total_price
FROM
    `smartycommerce.shopify_fivetran.customer_visit` AS customer_visit
INNER JOIN 
    `smartycommerce.shopify_fivetran.order` AS o_rder 
    ON customer_visit.order_id = o_rder.id
GROUP BY
    customer_visit.source;
