## Decision Log

In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made here, and will continue to update as the package evolves. 

### Using an Order's `created_timestamp` Instead of `processed_timestamp` 

In a similar vein to the above, in the customer cohort and daily shop models, we aggregate orders on a daily grain. To do so, we truncate the timestamp at which the order was _created_. In contrast, Shopify in-app reports truncate the timestamp at which the order was _processed_. This may also contribute to discrepancies when comparing the package models to in-app reports. We felt that the creation timestamp makes more sense to use in reality, but please reach out if you have other thoughts by opening an [issue](https://github.com/fivetran/dbt_shopify/issues/new?assignees=&labels=enhancement&template=feature-request.yml&title=%5BFeature%5D+%3Ctitle%3E).

### Creating Empty Tables for Refunds, Order Line Refunds, Order Adjustments, and Discount Codes

Source tables related to `refunds`, `order_line_refunds`, `order_adjustments`, and `discount_codes` are created in the Shopify schema dyanmically. For example, if your shop has not incurred any refunds, you will not have a `refund` table yet until you do refund an order. 

Thus, the source package will create empty (1 row of all `NULL` fields) staging models if these source tables do not exist in your Shopify schema yet, and the transform package will work seamlessly with these empty models. Once `refund`, `order_line_refund`, `order_adjustment`, or `discount_code` exists in your schema, the source and transform packages will automatically reference the new populated table(s). ([example](https://github.com/fivetran/dbt_shopify/blob/main/models/rest/staging/tmp/stg_shopify__refund_tmp.sql)). 

> In previous versions of the package, you had to manually enable or disable transforms of `refund`, `order_line_refund`, or `order_adjustment` through variables. Because this required you to monitor your Shopify account/schema and update the variable(s) accordingly, we decided to pursue a more automated solution.

### Keeping Deleted Entities 

Instead of automatically filtering out records where `_fivetran_deleted` is `true`, the Shopify package keeps these soft-deleted records, as they may persist as foreign keys in other tables. The package merely renames the deleted-flag to `is_deleted`, which you can filter out if you choose.

### Accepted Value Test Severity

We test the following columns for accepted values because their values are hard-coded to be pivoted out into columns and/or used as `JOIN` conditions in downstream models.
- `stg_shopify__price_rule.target_type`: accepted values are `line_item`, `shipping_line`
- `stg_shopify__price_rule.value_type`: accepted values are `percentage`, `fixed_amount`
- `stg_shopify__fulfillment.status`: accepted values are `pending`, `open`, `success`, `cancelled`, `error`, `failure`

We have chosen to make the severity of these tests `warn`, as non-accepted values will be filtered out in the transformation models. They will not introduce erroneous data.

### Currency

All monetary values reported in the Shopify end models are in the default currency of your Shop.

### Incremental Strategy
The models having an incremental strategy were chosen based on the size of their upstream models. We wanted to be selective rather than make all models incremental due to the complexity of changes and maintenance required when stacking incrementals. However, we would still like to hear feedback on these choices. 

The strategies for each model are:

| Model | Bigquery/Databricks strategy | Snowflake/Postgres/Redshift strategy |
| --- | --- | --- |
| `shopify__customer_cohorts` | insert_overwrite | delete+insert |
| `shopify__customer_email_cohorts` | insert_overwrite | delete+insert |
| `shopify__discounts` | merge | delete+insert |
| `shopify__order_lines` | merge | delete+insert |
| `shopify__orders` | merge | delete+insert |
| `shopify__transactions` | merge | delete+insert |

For Bigquery and Databricks, insert_overwrite was chosen for the cohort models since the date_day grain provides a suitable column to partition on. 
Merge was chosen for the remaining models since this can handle updates to the records.
