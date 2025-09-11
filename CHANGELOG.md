# dbt_shopify v0.22.0

[PR #121](https://github.com/fivetran/dbt_shopify/pull/121) includes the following updates:

## Under the Hood
- Updates the `quickstart.yml` file so that GraphQL models are exposed and available to run in Fivetran Quickstart.

# dbt_shopify v0.21.1

[PR #119](https://github.com/fivetran/dbt_shopify/pull/119) includes the following updates:

## Bug Fixes
- Updated the join of the `product_variant_media` CTE in the `shopify__inventory_levels` and `shopify_gql__inventory_levels` models to use a left join. This ensures inventory items are not excluded when no media exists, and unmatched records will now display null media fields.
  - This join fix is only relevant when either vars `shopify_using_product_variant_media` or `shopify_gql_using_product_variant_media` are set to true.

## Under the Hood
- Updated seed data to properly recreate and test the `*__inventory_levels` bug when either of the `*_using_product_variant_media` variables are enabled.
- Added row_count consistency tests for the `*__inventory_levels` models.

# dbt_shopify v0.21.0
[PR #118](https://github.com/fivetran/dbt_shopify/pull/118) includes the following updates:

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests within this package and the upstream `dbt_shopify_source` to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.
  - Removed all `accepted_values` tests.

# dbt_shopify v0.20.0

[PR #113](https://github.com/fivetran/dbt_shopify/pull/113) introduces the following updates:

## Feature Update: GraphQL API Support

Fivetran very recently released a new version of the Shopify connector that leverages Shopify's newer [GraphQL](https://shopify.dev/docs/apps/build/graphql) API instead of the REST API, as Shopify deprecated the REST API in October 2024. The GraphQL and REST API-based schemas are slightly different, but this package is designed to run for either or, not both. It will do so based on the value of the `shopify_api` variable.

By default, `shopify_api` is set to `rest` and will run the `shopify__*` models in the [`rest`](https://github.com/fivetran/dbt_shopify/tree/main/models/rest) folder. If you would like to run the package on a GraphQL-based schema, adjust `shopify_api` accordingly. This will run the `shopify_gql__*` models in the [`graphql`](https://github.com/fivetran/dbt_shopify/tree/main/models/graphql) folder:

> This variable is dynamically configured for you in Fivetran Quickstart based on your Shopify connection details.

```yml
vars:
  shopify_api: graphql # By default = rest. Must be lowercase
```

Overall, the package aims for parity across the different API versions and aligns column names with their REST names, **if the fields are supported in GraphQL**. There will be a 1:1 relationship between REST API and GraphQL based end models, but please note that the following source tables are not present in GraphQL and will therefore not be included in any transformations:
- `ABANDONED_CHECKOUT_SHIPPING_LINE`: The absence of this table will result in no `shopify_gql__discounts.total_abandoned_checkout_shipping_price` field.
- `ORDER_URL_TAG`: The absence of this table will result in no `shopify_gql__orders.order_url_tags` field.

# dbt_shopify v0.19.1

[PR #108](https://github.com/fivetran/dbt_shopify/pull/108) includes the following updates:

## Bug Fixes
- Removed the unique combination of columns test for the `int_shopify__discount_code_enriched` model.
  - This has been removed as it's already tested in the [shopify__discounts](https://github.com/fivetran/dbt_shopify/blob/7e174a8367ee063b5025172734bdcd19fe802606/models/shopify.yml#L991-L997) end model and is configured to warn instead of fail. As such, we can remove the test from the intermediate level.

[PR #109](https://github.com/fivetran/dbt_shopify/pull/109) includes the following updates:

### Under the Hood - July 2025 Updates
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.
- Migrated `flags` (e.g., `send_anonymous_usage_stats`, `use_colors`) from `sample.profiles.yml` to `integration_tests/dbt_project.yml`.
- Updated `maintainer_pull_request_template.md` with improved checklist.
- Updated Python image version to `3.10.13` in `pipeline.yml`.
- Updated `.gitignore` to exclude additional DBT, Python, and system artifacts.

# dbt_shopify v0.19.0

[PR #104](https://github.com/fivetran/dbt_shopify/pull/104) introduces the following updates:

## Schema & Data Updates
**25 new models -- 7 deprecated models -- 8 potential breaking changes**

| Data Model                                                                                                                                               | Change Type | Old Name                     | New Name                                             | Notes                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `shopify__product_image_metafields`             | Deprecated Metafields Model |   |          | Deprecated the `product_image` source table.    |
| `stg_shopify__discount_code`                  | Deprecated Staging Model |   |          | Deprecated the `discount_code` source table.     |
| `stg_shopify__discount_code_tmp`                     | Deprecated Temp Model |   |          | Deprecated the `discount_code_app` source table.    |
| `stg_shopify__price_rule`                     | Deprecated Staging Model |   |          | Deprecated the `price_rule` source table.     |
| `stg_shopify__price_rule_tmp`            | Deprecated Temp Model |   |          | Deprecated the `price_rule` source table.    |
| `stg_shopify__product_image`                    | Deprecated Staging Model |   |          | Deprecated the `product_image` source table.     |
| `stg_shopify__product_image_tmp`                    | Deprecated Temp Model |   |          | Deprecated the `product_image` source table.    |
| [shopify__inventory_levels](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__inventory_levels)                      |  Renamed Columns |  `variant_image_id`  |   `variant_media_id`       | Replaced `product_variant` source with `product_variant_media` source, `variant_media_id` only populates if `product_variant_media` is being leveraged.    |
| [shopify__order_lines](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__order_lines)                      |  Renamed Columns |  `image_id`  |   `media_id`       |  Replaced `product_variant` source with `product_variant_media` source, `media_id` only populates if `product_variant_media` is being leveraged.    |
| [stg_shopify__product_variant](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_variant)                      | Deprecated Columns | `image_id`  |         | No longer supported in `product_variant` source.    |
| [shopify__discounts](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__discounts)                      |  Deprecated Columns  |  `price_rule_id`, `allocation_limit`, `price_rule_created_at`, `price_rule_updated_at`, `prereq_min_quantity`, `prereq_max_shipping_price`, `prereq_min_subtotal`, `prereq_min_purchase_quantity_for_entitlement`, `prereq_buy_x_get_this`, `prereq_buy_this_get_y`                          |        | Removing fields from deprecated `price_rule` source.       |
| [shopify__discounts](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__discounts)                      |  Renamed Columns  |  `is_once_per_customer`, `customer_selection`                          |   `applies_once_per_customer`, `customer_selection_all_customers`     | Renaming fields from deprecated `price_rule` source to their equivalent fields in the `discount_*` sources.      |
| [shopify__discounts](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__discounts)                      |  New Columns  |      |   `discount_type`, `codes_count`, `codes_precision`, `combines_with_order_discounts`, `combines_with_product_discounts`, `combines_with_shipping_discounts`, `total_sales_amount`, `total_sales_currency_code`, `description`, `application_type`    | Bringing in new fields that are common to the new `discount_code_*` sources.      |
| [shopify__products](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__products)                      |   Renamed Columns   |      `has_product_image`                        |  `has_product_media`        |  Switching from deprecated `product_image` to new `product_media` source.          |
| [int_shopify__products_with_aggregates](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.int_shopify__products_with_aggregates)                      |   Renamed Columns   |      `has_product_image`                         |  `has_product_media`        |   Switching from deprecated `product_image` to new `product_media` source.              |
| [int_shopify__discount_code_enriched](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.int_shopify__discount_code_enriched)                      |  New Intermediate Model   |                              |        | Aggregated and unioned discount code metadata from `discount_code_app`, `discount_code_basic`, `discount_code_bxgy`, `discount_code_free_shipping` source tables.               |
| [stg_shopify__discount_code_app](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_app)                      |  New Staging Model   |                              |        | Source: `discount_code_app` table.               |
| [stg_shopify__discount_code_basic](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_basic)                  |  New Staging Model  |                              |                 |  Source: `discount_code_basic` table.                      |
| [stg_shopify__discount_code_bxgy](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_bxgy)                    |  New Staging Model |                              |                |  Source: `discount_code_bxgy` table.                         |
| [stg_shopify__discount_code_free_shipping](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_free_shipping) |  New Staging Model  |                              |          |  Source: `discount_code_free_shipping` table.                         |
| [stg_shopify__discount_application](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_application)                 |  New Staging Model |                              |              | Source: `discount_application` table.    |
| [stg_shopify__discount_allocation](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_allocation)                   |  New Staging Model   |                              |              | Source: `discount_allocation` table.                           |
| [stg_shopify__discount_basic_code](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_basic_code)                  |  New Staging Model  |                              |                  | Source: `discount_basic_code` table.  |
| [stg_shopify__discount_redeem_code](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_redeem_code)                |  New Staging Model   |                              |              | Via Source: `discount_redeem_code` table.           |
| [stg_shopify__media](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__media)                               | New Staging Model  | | | Source: `media` table.  |
| [stg_shopify__media_image](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__media_image)                               |  New Staging Model   | |   |  Source: `media_image` table.       
| [stg_shopify__product_media](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_media)                               |  New Staging Model    | | | Source: `product_media` table.        |
| [stg_shopify__product_variant_media](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_variant_media)                               | New Staging Model |          |          | Source: `product_variant_media`  table.               |
| [stg_shopify__discount_code_app_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_app_tmp)                      | New Temp Model |          |          | Source: `discount_code_app` table.           |
| [stg_shopify__discount_code_basic_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_basic_tmp)                  | New Temp Model |          |          | Source:  `discount_code_basic` table.         |
| [stg_shopify__discount_code_bxgy_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_bxgy_tmp)                    | New Temp Model |          |          | Source: `discount_code_bxgy` table.          |
| [stg_shopify__discount_code_free_shipping_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_code_free_shipping_tmp) | New Temp Model |          |          | Source: `discount_code_free_shipping` table. |
| [stg_shopify__discount_application_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_application_tmp)                 | New Temp Model |          |          | Source: `discount_application` table.        |
| [stg_shopify__discount_allocation_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_allocation_tmp)                   | New Temp Model |          |          | Source: `discount_allocation` table.         |
| [stg_shopify__discount_basic_code_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_basic_code_tmp)                  | New Temp Model |          |          | Source: `discount_basic_code` table.         |
| [stg_shopify__discount_redeem_code_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__discount_redeem_code_tmp)                | New Temp Model |          |          | Source: `discount_redeem_code` table.        |
| [stg_shopify__media_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__media_tmp)                                                | New Temp Model |          |          | Source: `media` table.                       |
| [stg_shopify__media_image_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__media_image_tmp)                                   | New Temp Model |          |          | Source: `media_image`  table.                 |
| [stg_shopify__product_media_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_media_tmp)                               | New Temp Model |          |          | Source: `product_media`  table.               |
| [stg_shopify__product_variant_media_tmp](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_variant_media_tmp)                               | New Temp Model |          |          | Source: `product_variant_media`  table.               |

## Release Notes
- Applied the above schema changes in accordance with the April 2025 Fivetran connector update to accommodate new changes in the Shopify API. [See the release notes for more details](https://fivetran.com/docs/connectors/applications/shopify/changelog#april2025).
- Major updates included:
  - Created the `int_shopify__discount_code_enriched` intermediate model to union/join together new `discount_code_*`, `discount_redeem_code` and `discount_application` sources. This replaces deprecated `discount_code`/`price_rule` source data which flows into `shopify__discounts`
  - Removal of the `shopify__product_image_metafields` model, as the `product_image` source is no longer supported.
  - Replaced fields `variant_image_id` in `shopify__inventory_levels` and `image_id` in `shopify__order_lines` with `variant_media_id` from the new `product_variant_media` source.
  - See the concurrent `shopify_source` [v0.18.0 release update](https://github.com/fivetran/dbt_shopify_source/releases/tag/v0.18.0) to learn more about other schema updates. 

## Quickstart Updates
- Added `shopify__line_item_enhanced` to public models to allow customer access. 
- Introduced table variables `shopify_using_discount_code_app` and `shopify_using_product_variant_media`, which is enabled when `discount_code_app` and `product_variant_media` source tables are selected in the Fivetran connector schema tab. 

## Feature Updates
- If users are utilizing the `discount_code_app` and/or `product_variant_media` sources, these models can be enabled by setting the variables `shopify_using_discount_code_app` and/or `shopify_using_product_variant_media` to `true`.  More instructions [are available in the README](https://github.com/fivetran/dbt_shopify/blob/main/README.md#step-4-disable-models-for-non-existent-sources).

## Under the Hood
- Created and removed seed files to ensure end models run successfully.
- Created new vertical integrity test to ensure discount code counts match between `shopify__discounts` and its upstream source models.
- Enable `shopify__line_item_enhanced` by default by setting the `shopify__standardized_billing_model_enabled` variable to be `true`.

## Documentation Notes
- Added/removed yml documentation for new/deprecated models respectively.

# dbt_shopify v0.18.0
This release includes the following updates:

## Dependency Changes
- Removed the dependency on [calogica/dbt_date](https://github.com/calogica/dbt-date) as it is no longer actively maintained. To maintain functionality, the highly leveraged `dbt_date.convert_timezone` macro (see [README](https://github.com/fivetran/dbt_shopify?tab=readme-ov-file#step-5-setting-your-timezone) for how to use) has been replicated within the Shopify Source package's `macros/fivetran_date_macros` [folder](https://github.com/fivetran/dbt_shopify_source/tree/main/macros/fivetran_date_macros/fivetran_convert_timezone.sql) with minimal modifications. It has been prefixed with `fivetran_` to avoid potential naming conflicts ([Source PR #98](https://github.com/fivetran/dbt_shopify_source/pull/98)):
  - `dbt_date.convert_timezone` -> `shopify_source.fivetran_convert_timezone`

## Under the Hood
- Added consistency data validation tests for all remaining end models ([PR #102](https://github.com/fivetran/dbt_shopify/pull/102)):
  - `shopify__customer_email_cohorts`
  - `shopify__customer_emails`
  - `shopify__discounts`
  - `shopify__order_lines`
  - `shopify__orders`
  - `shopify__transactions`

# dbt_shopify v0.17.0

[PR #100](https://github.com/fivetran/dbt_shopify/pull/100) includes the following updates:  

## Breaking Changes  
- In the source package, introduced the `inventory_quantity` source and the `stg_shopify__inventory_quantity` model to support downstream quantity tracking.
  - This replaces the deprecated `available_quantity` column in `stg_shopify__inventory_level`.  
  - See the [v0.16.0 dbt_shopify_source release notes](https://github.com/fivetran/dbt_shopify_source/releases/tag/v0.16.0) for more details.
- Updated model `shopify__inventory_levels` to add the following columns based on the `quantity` field from `stg_shopify__inventory_quantity`:  
  - `available_quantity` 
  - `committed_quantity`  
  - `damaged_quantity`  
  - `incoming_quantity`  
  - `on_hand_quantity`  
  - `quality_control_quantity`  
  - `reserved_quantity`  
  - `safety_stock_quantity` 

## Documentation  
- Added definitions for the new fields.  

## Under the Hood  
- Added seed `inventory_quantity_data` and macro `get_inventory_quantity_columns` to support the new `inventory_quantity` source.  

# dbt_shopify v0.16.1
[PR #99](https://github.com/fivetran/dbt_shopify/pull/99) includes the following updates:

## Bug Fixes
- Updated the `get_metafields` macro to support multiple reference values, ensuring compatibility with both the Shopify GraphQL API (ex: 'PRODUCTVARIANT' from the `product_variant` source) and the deprecated REST API (previously 'variant' for `product_variant`). [See the Shopify API docs for more information](https://shopify.dev/docs/api/admin-graphql/2025-01/objects/metafield).
  - Updated `reference_value` parameter to `reference_values` to grab lists of reference values rather than a single string value. Now all records from `stg_shopify__metafield` are properly added to the relevant metafield models.
  - Added `id_column` parameter to explicitly specify what field in the staging model should be joined on to properly unpivot the metafields. 

## Under the Hood
- Updated the `shopify_metafield_data` seed to validate the functionality of the `get_metafields` macro, ensuring it correctly retrieves metafield data for all supported reference values.

# dbt_shopify v0.16.0
This release includes the following updates:

## Bug Fixes
- Removed incremental logic in the following end models 
([PR #97](https://github.com/fivetran/dbt_shopify/pull/97)):
  - `shopify__discounts`
  - `shopify__order_lines`
  - `shopify__orders`
  - `shopify__transactions`
- Incremental strategies were removed from these models due to potential inaccuracies from incremental runs. For instance, the `new_vs_repeat` field in `shopify__orders` could produce incorrect results during incremental runs. To ensure consistency, this logic was removed across all warehouses. If the previous incremental functionality was valuable to you, please consider opening a feature request to revisit this approach.

## [Upstream Under-the-Hood Updates from `shopify_source` Package](https://github.com/fivetran/dbt_shopify_source/releases/tag/v0.15.0)
- (Affects Redshift only) Creates new `shopify_union_data` macro to accommodate Redshift's treatment of empty tables.
  - For each staging model, if the source table is not found in any of your schemas, the package will create a table with one row with null values for Redshift destinations. There will be no change in behavior in non-Redshift warehouses.
  - This is necessary as Redshift will ignore explicit data casts when a table is completely empty and materialize every column as a `varchar`. This throws errors in downstream transformations in the `shopify` package. The 1 row will ensure that Redshift will respect the package's datatype casts.

## Documentation
- Added Quickstart model counts to README. ([#96](https://github.com/fivetran/dbt_shopify/pull/96))
- Corrected references to connectors and connections in the README. ([#96](https://github.com/fivetran/dbt_shopify/pull/96))

# dbt_shopify v0.15.0

[PR #94](https://github.com/fivetran/dbt_shopify/pull/94) includes the following updates:
## Breaking Changes
- Updated columns with the connector changes released on January 6, 2025. See the [release notes](https://fivetran.com/docs/connectors/applications/shopify/changelog#january2025) for more details. 

- In the `shopify__inventory_levels` model, replaced the `cost` column with:
  - `unit_cost_amount`
  - `unit_cost_currency_code`

- Added the following columns to models:
  - `shopify__inventory_levels`:
    - `duplicate_sku_count`
    - `harmonized_system_code`
    - `inventory_history_url`
    - `legacy_resource_id`
    - `measurement_id`
    - `measurement_weight_value`
    - `measurement_weight_unit`
    - `is_tracked_editable_locked`
    - `tracked_editable_reason`
  - `shopify__inventory_levels` and `shopify__order_lines`:
    - `variant_is_available_for_sale`
    - `variant_display_name`
    - `variant_legacy_resource_id`
    - `variant_has_components_required`
    - `variant_sellable_online_quantity`
- Additionally, new columns were added in the upstream package. For more details, see the [dbt_shopify_source v0.14.0 release notes](https://github.com/fivetran/dbt_shopify_source/releases/tag/v0.14.0).

- Marked the following columns as deprecated in the documentation. These columns will return `null` values following the connector update, and customers should expect this behavior until the columns are fully removed in a future release.
  - `shopify__inventory_levels`:
    - `available_quantity`
    - `is_shipping_required`
    - `variant_fulfillment_service`
    - `variant_grams`
    - `variant_inventory_management`
    - `variant_option_1`
    - `variant_option_2`
    - `variant_option_3`
    - `variant_weight`
    - `variant_weight_unit`
  - `shopify__order_lines`:
    - `variant_fulfillment_service`
    - `variant_grams`
    - `variant_inventory_management`
    - `variant_option_1`
    - `variant_option_2`
    - `variant_option_3`
    - `variant_weight`
    - `variant_weight_unit`

## Under the Hood
- Updated `shopify_*_data` seed data to include new columns for the following tables:
  - `inventory_item`
  - `inventory_level`
  - `product_image`
  - `product_variant`

# dbt_shopify v0.14.0

[PR #92](https://github.com/fivetran/dbt_shopify/pull/92) includes the following updates:
## Breaking Changes
- Adds enable/disable config for the `metadata` staging model using the `shopify_using_metafield` variable (default `true`).
  - This variable is now a requirement for all `shopify__x_metafield` models.
- Adds enable/disable config for the `abandoned_checkout` staging models using the `shopify_using_abandoned_checkout` variable (default `true`):
   - `stg_shopify__abandoned_checkout`
   - `stg_shopify__abandoned_checkout_discount_code`
   - `stg_shopify__abandoned_checkout_shipping_line`.

   - Disabling `shopify_using_abandoned_checkout` will also disable the `int_shopify__daily_abandoned_checkouts` and `int_shopify__discounts__abandoned_checkouts` intermediate models, in addition to disabling `abandoned_checkout` references in end models (including `shopify__daily_shop`, `shopify__customers`, `shopify__customer_emails`, `shopify__customer_email_cohorts`, `shopify__customer_cohorts`, and `shopify__discounts`).
- For more information on how to enable/disable these tables, refer to the [README](https://github.com/fivetran/dbt_shopify/blob/main/README.md#step-4-disable-models-for-non-existent-sources). This will be a breaking change if you choose to disable these tables.

# dbt_shopify v0.13.2
[PR #89](https://github.com/fivetran/dbt_shopify/pull/89) includes the following changes:

## Bug Fixes
- Fixed an issue where the `shopify__customers` model incorrectly displayed NULL values for the `customer_tags` field for customers without orders. Updated the logic to ensure customer tags are retrieved even if no orders have been placed for that customer.

## Under the Hood
- Updated seed data to include customers without orders, verifying that their tags are correctly pulled through.
- Added consistency and integrity tests for the `shopify__customers` model to ensure accurate handling of customer tags for all customers.

# dbt_shopify v0.13.1
[PR #87](https://github.com/fivetran/dbt_shopify/pull/87) includes the following changes:

## Bug Fixes
- Coalesces the `backfill_lifetime_sums` fields from incremental loads, as well as `cohort_month_number` in the rare cases there are no orders from an incremental period. This fixes the issue of NULL values in the lifetime columns in `shopify__customer_cohorts` table. ([PR #86](https://github.com/fivetran/dbt_shopify/pull/86)).

## Under the Hood:
- Added consistency and integrity tests within `integration_tests` for the `shopify__customer_cohorts` model. ([PR #87](https://github.com/fivetran/dbt_shopify/pull/87)).

## Contributors
- [@advolut-team](https://github.com/advolut-team) ([PR #86](https://github.com/fivetran/dbt_shopify/pull/86))

# dbt_shopify v0.13.0
[PR #83](https://github.com/fivetran/dbt_shopify/pull/83) includes the following changes:

## Features
- Addition of the `shopify__line_item_enhanced` model. This model constructs a comprehensive, denormalized analytical table that enables reporting on key revenue, customer, and product metrics from your billing platform. It’s designed to align with the schema of the `*__line_item_enhanced` model found in Shopify, Recharge, Stripe, Zuora, and Recurly, offering standardized reporting across various billing platforms. To see the kinds of insights this model can generate, explore example visualizations in the [Fivetran Billing Model Streamlit App](https://fivetran-billing-model.streamlit.app/). Visit the app for more details.
  - This model is currently disabled by default. You may enable it by setting the `shopify__standardized_billing_model_enabled` as `true` in your `dbt_project.yml`.

## Under the Hood:
- Added consistency test within integration_tests for the `shopify__line_item_enhanced` model.

# dbt_shopify v0.12.2

[PR #84](https://github.com/fivetran/dbt_shopify/pull/84) includes the following changes:

## Feature
- Introduced the variable `shopify__calendar_start_date` to `shopify__calendar` to allow for the start date to be customized. This can be set in your `dbt_project.yml`. If not used, the default will start at `2019-01-01`. See the [README](https://github.com/fivetran/dbt_shopify/blob/main/README.md#Change-the-calendar-start-date) for more details. 

# dbt_shopify v0.12.1

## 🪲 Bug Fixes 🪛
- Added support for a new `delayed` fulfillment event status from Shopify. This produces a new `count_fulfillment_delayed` field in the `shopify__daily_shop` model ([PR #81](https://github.com/fivetran/dbt_shopify/pull/81)).

## 🚘 Under the Hood 🚘
- Added validation tests to be used by package maintainers to evaluate the consistency and integrity of subsequent model updates ([PR #82](https://github.com/fivetran/dbt_shopify/pull/82)).

## Contributors
- [@shreveasaurus](https://github.com/shreveasaurus) ([PR #81](https://github.com/fivetran/dbt_shopify/pull/81))

# dbt_shopify v0.12.0

[PR #76](https://github.com/fivetran/dbt_shopify/pull/76) includes the following updates: 

## 🚨 Breaking Changes 🚨
> ⚠️ Since the following changes are breaking, a `--full-refresh` after upgrading will be required.

- Performance improvements:
  - Added an incremental strategy for the following models. These models were picked for incremental materialization based on the size of their upstream sources. 
    - `shopify__customer_cohorts` (For Databricks SQL Warehouse destinations, this model is materialized as a table without support for incremental runs at this time.)
    - `shopify__customer_email_cohorts` (For Databricks SQL Warehouse destinations, this model is materialized as a table without support for incremental runs at this time.)
    - `shopify__discounts`
    - `shopify__order_lines`
    - `shopify__orders`
    - `shopify__transactions`
  - Updated the materialization of `shopify__orders__order_line_aggregates` to a table. This model draws on several large upstream sources and is also referenced in several downstream models, so this was done to improve performance. This model was not selected for incremental materialization since its structure was not conducive to incremental strategy.
- To reduce storage, updated the default materialization of the upstream staging models from tables to views. (See the [dbt_shopify_source CHANGELOG](https://github.com/fivetran/dbt_shopify_source/blob/main/CHANGELOG.md) for more details.)

## Features
- Added a default 7-day look-back to incremental models to accommodate late arriving records. The number of days can be changed by setting the var `lookback_window` in your dbt_project.yml. See the [Lookback Window section of the README](https://github.com/fivetran/dbt_shopify/blob/main/README.md#lookback-window) for more details. 
- Added macro `shopify_lookback` to streamline the lookback calculation.
- Updated the partitioning logic in window functions to use only the necessary columns, depending on whether the unioning feature is used. This benefits mainly Redshift destinations, which can see errors when the staging models are materialized as views. 

## 🪲 Bug Fixes 🪛
- Corrected the `fixed_amount_discount_amount` logic to appropriately bring in fixed amount discounts in `shopify__orders`. [PR #78](https://github.com/fivetran/dbt_shopify/pull/78)
- Removed the `index=1` filter in `stg_shopify__order_discount_code` in the `dbt_shopify_source` package to ensure all discount codes are brought in for every orders. For customers with multiple discount codes in an order, this could update the `count_discount_codes_applied` field in the `shopify__orders` and `shopify__daily_shop` models. [PR #78](https://github.com/fivetran/dbt_shopify/pull/78)

## Under the Hood
- Updated the maintainer PR template to the current format.
- Added integration testing pipeline for Databricks SQL Warehouse.
- Added macro `shopify_is_databricks_sql_warehouse` for detecting if a Databricks target is an All Purpose Cluster or a SQL Warehouse.

# dbt_shopify v0.11.0
[PR #74](https://github.com/fivetran/dbt_shopify/pull/74) includes the following updates: 

## 🚨 Breaking Changes 🚨
- Added `source_relation` to the `partition_by` clauses that determine the `customer_index` in the `int_shopify__customer_email_rollup` table. If the user is leveraging the union feature, this could change data values. 

## 🚘 Under The Hood 🚘
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Added additional casting in seed dependencies for above models `integration_tests/dbt_project.yml` to ensure local testing passed on null cases.

# dbt_shopify v0.10.0
## 🚨 Breaking Changes 🚨
- This release will be a breaking change due to the removal of below dependencies.
## Dependency Updates
- Removed the dependency on [dbt-expectations](https://github.com/calogica/dbt-expectations/releases) and updates [dbt-date](https://github.com/calogica/dbt-date/releases) dependencies to the latest version. ([PR #66](https://github.com/fivetran/dbt_shopify/pull/66/))

## Under the Hood
- Removed the `dbt_expectations.expect_table_row_count_to_equal_other_table` test that ensured no fanouts in the metafield models. We will be working to replace this with a similar test. ([PR #66](https://github.com/fivetran/dbt_shopify/pull/66/))

# dbt_shopify v0.9.0
([PR #61](https://github.com/fivetran/dbt_shopify/pull/61)) includes the following updates:
## Breaking Changes
These changes are made breaking due to changes in the source.

- In [June 2023](https://fivetran.com/docs/applications/shopify/changelog#june2023) the Shopify connector received an update which upgraded the connector to be compatible with the new [2023-04 Shopify API](https://shopify.dev/docs/api). As a result, the following fields have been removed as they were deprecated in the API upgrade: ([dbt_shopify_source PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

| **model** | **field removed** |
|-------|--------------|
| [stg_shopify__customer](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__customer) | `lifetime_duration` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `fulfillment_service` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `destination_location_*` fields |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `origin_location_*` fields |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `total_price_usd` |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `processing_method` |

- Please be aware that the removal of the fields from the staging models results in the removal of the fields in the relevant downstream models:

| **model** | **field removed** |
|-------|--------------|
| [shopify__customer](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__customer) | `lifetime_duration` |
| [shopify__customer_emails](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__customer_emails) | `lifetime_duration` |
| [shopify__order_lines](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__order_lines) | `fulfillment_service` |
| [shopify__order_lines](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__order_lines) | `destination_location_*` fields |
| [shopify__order_lines](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__order_lines) | `origin_location_*` fields |
| [shopify__orders](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__orders) | `total_price_usd` |
| [shopify__orders](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__orders) | `processing_method` |

## Documentation Updates
- The `shopify_using_shop_metafields` variable was added to the Adding Metafields of the README. It was erroneously omitted in a previous release. 
- Documentation provided in the README for how to connect sources when leveraging the union schema/database feature. 
- Removal of the `current_total_price` yml definition from the shopify__orders model as it was not being created in the model. 

# dbt_shopify v0.8.1

[PR #58](https://github.com/fivetran/dbt_shopify/pull/58) applies the following changes:

## Bug Fixes
- Adjusts the `int_shopify__customer_email_rollup` model to aggregate _distinct_ `customer_ids`.
- Ensures that each order is tagged with the orderer's `email` before aggregating order metrics in `int_shopify__emails__order_aggregates`.

## Under the Hood
- Ensures transaction `kinds` are being read correctly by applying a `lower()` function. 
- Removes unused and potentially problematic fields from `int_shopify__customer_email_rollup`. The removed fields include `orders_count` and `total_spent`, which are actually calculated in `int_shopify__emails__order_aggregates` before being passed to `shopify__customer_emails` (which is unaffected by this change).
- Removes `updated_timestamp` and `created_timestamp` from `shopify__customer_emails`. Refer to the following fields instead:
  - `first_account_created_at`
  - `last_account_created_at`
  - `last_updated_at`
- Incorporates the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job ([PR #57](https://github.com/fivetran/dbt_shopify/pull/57)).
- Updates the pull request [templates](/.github) ([PR #57](https://github.com/fivetran/dbt_shopify/pull/57)).

## Related-Package Releases:
- https://github.com/fivetran/dbt_shopify_holistic_reporting/releases/tag/v0.4.0

# dbt_shopify v0.8.0

Lots of new features ahead!! We've revamped the package to keep up-to-date with new additions to the Shopify connector and feedback from the community. 

This release does include 🚨 **Breaking Changes** 🚨.

## Documentation 
- Updated README documentation updates for easier navigation and setup of the dbt package ([PR #44](https://github.com/fivetran/dbt_shopify/pull/44)).
- Created the [DECISIONLOG](https://github.com/fivetran/dbt_shopify/blob/main/DECISIONLOG.md) to log discussions and opinionated stances we took in designing the package ([PR #43](https://github.com/fivetran/dbt_shopify/pull/43/files)).

## Under the Hood
- Ensured Postgres compatibility! ([PR #44](https://github.com/fivetran/dbt_shopify/pull/44))
- Addition of the calogica/dbt_expectations package for more robust testing ([PR #50](https://github.com/fivetran/dbt_shopify/pull/50)).
- Got rid of the `shopify__using_order_adjustment`, `shopify__using_order_line_refund`, and `shopify__using_refund` variables. Instead, the package will automatically create empty versions of the related models until the source `refund`, `order_line_refund`, and `order_adjustment` tables exist in your schema. See DECISIONLOG for more details ([Source PR #45](https://github.com/fivetran/dbt_shopify_source/pull/45), [PR #46](https://github.com/fivetran/dbt_shopify/pull/46)).

## Bug Fixes
- In the intermediate models, we aggregate a lot of metrics and join them together. In previous versions of the package, some order line aggregates were being doubled if their parent order had multiple kinds of transactions, ie a customer used a gift card for part of the purchase ([PR #51](https://github.com/fivetran/dbt_shopify/pull/51)).

## Feature Updates
- **New end model alert**: 
  - The package now includes customer models that are based on _email_ rather than _customer_id_ ([PR #45](https://github.com/fivetran/dbt_shopify/pull/45)):
    - [`shopify__customer_emails`](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__customer_emails)
    - [`shopify__customer_email_cohorts`](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__customer_email_cohorts)
  - [`shopify__daily_shop`](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__daily_shop)  ([PR #48](https://github.com/fivetran/dbt_shopify/pull/48))
  - [`shopify__inventory_levels`](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__inventory_levels) ([PR #46](https://github.com/fivetran/dbt_shopify/pull/46))
  - [`shopify__discounts`](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.shopify__discounts) ([PR #47](https://github.com/fivetran/dbt_shopify/pull/47), [PR #48](https://github.com/fivetran/dbt_shopify/pull/48))
- Metafield support! This package now supports metafields for the collection, customer, order, product_image, product, product_variant, and shop objects. If enabled (see the [README](https://github.com/fivetran/dbt_shopify#adding-metafields) for more details), respective `shopify__[object]_metafields` models will materialize with **all** metafields defined within the `metafield` source table appended to the object. ([PR #50](https://github.com/fivetran/dbt_shopify/pull/50))
- `shopify_<default_source_table_name>_identifier` variables added if an individual source table has a different name than the package expects ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).
- Addition of the `shopify_timezone` variable, which converts ALL timestamps included in the package (including `_fivetran_synced`) to a single target timezone in IANA Database format, ie "America/Los_Angeles" ([PR #41](https://github.com/fivetran/dbt_shopify_source/pull/41)).
- The declaration of passthrough variables within your root `dbt_project.yml` has changed (but is backwards compatible). To allow for more flexibility and better tracking of passthrough columns, you will now want to define passthrough columns in the following format ([PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
> This applies to all passthrough columns within the `dbt_shopify_source` package and not just the `customer_pass_through_columns` example. See the README for which models have passthrough columns.
```yml
vars:
  customer_pass_through_columns:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
      transform_sql: "cast(field_alias as string)" # Optional: If you wish to define the datatype or apply a light transformation.
```
- The following *source* fields have been added to (➕) or removed from (➖) their respective models ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39), [PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
  - `shopify__orders`:
    - ➕ `total_discounts_set`
    - ➕ `total_line_items_price_set`
    - ➕ `total_price_usd`
    - ➕ `total_price_set`
    - ➕ `total_tax_set`
    - ➕ `total_tip_received`
    - ➕ `is_deleted`
    - ➕ `app_id`
    - ➕ `checkout_id`
    - ➕ `client_details_user_agent`
    - ➕ `customer_locale`
    - ➕ `order_status_url`
    - ➕ `presentment_currency`
    - ➕ `is_confirmed`
  - `shopify__customers`:
    - ➕ `note`
    - ➕ `lifetime_duration`
    - ➕ `currency`
    - ➕ `marketing_consent_state` (coalescing of `email_marketing_consent_state` and deprecated `accepts_marketing` field)
    - ➕ `marketing_opt_in_level` (coalescing of `email_marketing_consent_opt_in_level` and deprecated `marketing_opt_in_level` field)
    - ➕ `marketing_consent_updated_at` (coalescing of `email_marketing_consent_consent_updated_at` and deprecated `accepts_marketing_updated_at` field)
    - ➖ `accepts_marketing`/`has_accepted_marketing`
    - ➖ `accepts_marketing_updated_at`
    - ➖ `marketing_opt_in_level`
  - `shopify__order_lines`:
    - ➕ `pre_tax_price_set`
    - ➕ `price_set`
    - ➕ `tax_code`
    - ➕ `total_discount_set`
    - ➕ `variant_title`
    - ➕ `variant_inventory_management`
    - ➕ `properties`
    - ( ) `is_requiring_shipping` is renamed to `is_shipping_required`
  - `shopify__products`:
    - ➕ `status`
- The following *transformed* fields have been added to their respective models:
  - `shopify__orders` 
    - `shipping_discount_amount` ([PR #47](https://github.com/fivetran/dbt_shopify/pull/47))
    - `percentage_calc_discount_amount` ([PR #47](https://github.com/fivetran/dbt_shopify/pull/47))
    - `fixed_amount_discount_amount` ([PR #47](https://github.com/fivetran/dbt_shopify/pull/47))
    - `count_discount_codes_applied` ([PR #47](https://github.com/fivetran/dbt_shopify/pull/47))
    - `order_tags` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `order_url_tags` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `number_of_fulfillments` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `fulfilmment_services` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `tracking_companies` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `tracking_numbers` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
  - `shopify__products` 
    - `collections` ([PR #46](https://github.com/fivetran/dbt_shopify/pull/46))
    - `tags` ([PR #46](https://github.com/fivetran/dbt_shopify/pull/46))
    - `count_variants` ([PR #46](https://github.com/fivetran/dbt_shopify/pull/46))
    - `has_product_image` ([PR #46](https://github.com/fivetran/dbt_shopify/pull/46))
    - `quantity_sold` renamed to `total_quantity_sold` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `avg_quantity_per_order_line` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `product_total_discount` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `product_avg_discount_per_order_line` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `product_total_tax` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `product_avg_tax_per_order_line` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
  `shopify__customers` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `lifetime_abandoned_checkouts`
    - `customer_tags`
    - `average_order_value` renamed to `avg_order_value`
    - `lifetime_total_amount` renamed to `lifetime_total_net`
    - `avg_quantity_per_order`
    - `lifetime_total_tax`
    - `avg_tax_per_order`
    - `lifetime_total_discount`
    - `avg_discount_per_order`
    - `lifetime_total_shipping`
    - `avg_shipping_per_order`
    - `lifetime_total_shipping_with_discounts`
    - `lifetime_total_shipping_tax`
    - `avg_shipping_tax_per_order`
    - `avg_shipping_with_discounts_per_order`
  - `shopify__order_lines` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `restock_types`
    - `order_line_tax`
  - `shopify__transactions` ([PR #49](https://github.com/fivetran/dbt_shopify/pull/49))
    - `payment_method`
    - `parent_kind`
    - `parent_created_timestamp`
    - `parent_amount`
    - `parent_status`

## dbt_shopify v0.7.0
## 🚨 Breaking Changes 🚨:
[PR #40](https://github.com/fivetran/dbt_shopify/pull/40) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_shopify v0.6.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_shopify_source`. Additionally, the latest `dbt_shopify_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

- The `union_schemas` and `union_databases` variables have been replaced with `shopify_union_schemas` and `shopify_union_databases` respectively. This allows for multiple packages with the union ability to be used and not locked to a single variable that is used across packages.

# dbt_shopify v0.1.0 -> v0.5.2
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
