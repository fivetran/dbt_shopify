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
