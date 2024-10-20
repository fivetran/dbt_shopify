-- source with the highest sales in the last year
SELECT
    sales_by_traffic_referrer.source,
    sales_by_traffic_referrer.total_price
  FROM
    `smartycommerce.shopify_fivetran.sales_by_traffic_referrer` AS sales_by_traffic_referrer
  WHERE sales_by_traffic_referrer.total_price = (
    SELECT
        max(sales_by_traffic_referrer_0.total_price)
      FROM
        `smartycommerce.shopify_fivetran.sales_by_traffic_referrer` AS sales_by_traffic_referrer_0
  );

  --------------
  -- the total sales from Facebook in the last year
SELECT
    sum(sales_by_traffic_referrer.total_price)
  FROM
    `smartycommerce.shopify_fivetran.sales_by_traffic_referrer` AS sales_by_traffic_referrer
  WHERE sales_by_traffic_referrer.source = 'Facebook'
   AND sales_by_traffic_referrer.num_orders > 0;