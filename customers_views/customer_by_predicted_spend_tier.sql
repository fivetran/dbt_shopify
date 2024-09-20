SELECT 
    CONCAT(customer.first_name," ", customer.last_name) AS customer_name,
    customer_tag.index,
    customer.email_marketing_consent_state,
    MAX(`order`.created_at) AS last_order_date,
    COUNT(`order`.id) AS total_orders,
    SUM(`order`.total_price) AS total_amount_spent
FROM
    `smartycommerce.shopify_fivetran.customer` AS customer
    INNER JOIN `smartycommerce.shopify_fivetran.customer_tag` AS customer_tag ON customer.id = customer_tag.customer_id
    INNER JOIN `smartycommerce.shopify_fivetran.order` AS `order` ON customer.id = `order`.customer_id
GROUP BY 1, 2, 3
