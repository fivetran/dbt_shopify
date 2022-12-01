## Decision Log

### Refund/Return Timestamp Mismatch

In validating metrics with the Sales over Time reports in the Shopify UI, you may detect discrepancies in reported revenue. A known difference between this package's reporting and the Shopify UI is that Shopify's UI will report refunded revenue on the date that the _return was processed_ (see Shopify [docs](https://help.shopify.com/en/manual/reports-and-analytics/shopify-reports/report-types/sales-report)), whereas this package reports on the date the _order was placed_. So, if a customer placed an order amounting to $50 on November 30th, 2022 and fully returned it on December 1st, 2022, the package would report $0 net sales for this customer on November 30th, while Shopify would report $50 in sales on November 30th and -$50 on December 1st. 

We felt that reporting on the order date made more sense in reality, but, if you feel differently, please reach out and create a Feature Request. To align with the Shopify method yourself, this would most likely involve aggregating `transactions` data (relying on the `kind` column to determine sales vs returns) instead of `orders`.