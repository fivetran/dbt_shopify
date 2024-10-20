WITH sessions AS (
    SELECT
        DATE_TRUNC(occurred_at, MONTH) AS month,
        COUNT(DISTINCT id) AS total_sessions
    FROM
        `smartycommerce.shopify_fivetran.customer_visit`
    GROUP BY
        month
),
carts AS (
    SELECT
        DATE_TRUNC(created_at, MONTH) AS month,
        COUNT(DISTINCT id) AS total_carts
    FROM
        `smartycommerce.shopify_fivetran.abandoned_checkout`
    GROUP BY
        month
),
checkouts AS (
    SELECT
        DATE_TRUNC(created_at, MONTH) AS month,
        COUNT(DISTINCT id) AS total_checkouts
    FROM
        `smartycommerce.shopify_fivetran.abandoned_checkout`
    GROUP BY
        month
),
orders AS (
    SELECT
        DATE_TRUNC(created_at, MONTH) AS month,
        COUNT(DISTINCT id) AS total_orders_placed
    FROM
        `smartycommerce.shopify_fivetran.order`
    GROUP BY
        month
)
SELECT
    CAST(sessions.month AS DATE) AS month,  -- Format month as 'YYYY-MM-DD'
    sessions.total_sessions,
    carts.total_carts,
    checkouts.total_checkouts,
    orders.total_orders_placed,
    ROUND(orders.total_orders_placed / sessions.total_sessions, 2) AS total_conversion
FROM
    sessions
LEFT JOIN carts ON sessions.month = carts.month
LEFT JOIN checkouts ON sessions.month = checkouts.month
LEFT JOIN orders ON sessions.month = orders.month
ORDER BY
    sessions.month;
