# dbt_shopify_source v0.18.0

[PR #100](https://github.com/fivetran/dbt_shopify_source/pull/100) includes the following updates:

## Schema And Data Updates
**24 new models -- 6 deprecated models -- 1 deprecated field**

| Data Model                                                                                                                                               | Change Type | Old Name                     | New Name                                             | Notes                                                                                    |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | ---------------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `stg_shopify__discount_code`                  | Deprecated Staging Model |   |          | Deprecated the `discount_code` source table.     |
| `stg_shopify__discount_code_tmp`                     | Deprecated Temp Model |   |          | Deprecated the `discount_code_app` source table.    |
| `stg_shopify__price_rule`                      | Deprecated Staging Model |   |          | Deprecated the `price_rule` source table.     |
| `stg_shopify__price_rule_tmp`                      | Deprecated Temp Model |   |          | Deprecated the `price_rule` source table.    |
| `stg_shopify__product_image`                    | Deprecated Staging Model |   |          | Deprecated the `product_image` source table.     |
| `stg_shopify__product_image_tmp`                       | Deprecated Temp Model |   |          | Deprecated the `product_image` source table.    |
| [stg_shopify__product_variant](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify.stg_shopify__product_variant) | Deprecated Columns | `image_id`  |   None       | No longer supported in `product_variant`.    |
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
  - Deprecated staging models and field that stem from the `discount_code`, `price_rule`, `product_image` sources, and `image_id` in the `product_variant` table.
  - New models created that originate from the `discount_code_app`, `discount_code_basic`, `discount_code_bxgy`. `discount_code_free_shipping`, `discount_application`, `discount_allocation`, `product_image`, `product_variant_media`, `media`, `media_image` source tables. 

## Feature Updates
- If users are utilizing the `discount_code_app` and/or `product_variant_media` sources, these models can be enabled by setting the variables `shopify_using_discount_code_app` and/or `shopify_using_product_variant_media` respectively to `true`.  More instructions [are available in the README](https://github.com/fivetran/dbt_shopify_source/blob/main/README.md#step-4-disable-models-for-non-existent-sources).

# Under the Hood
- Created and removed seed files to ensure end models in the concurrent `dbt_shopify` [release](https://github.com/fivetran/dbt_shopify/releases/tag/v0.19.0) run successfully.

## Documentation Notes
- Added/removed yml documentation for new/deprecated models and fields.

# dbt_shopify_source v0.17.0

[PR #98](https://github.com/fivetran/dbt_shopify_source/pull/98) includes the following updates:

## Dependency Changes
- Removed the dependency on [calogica/dbt_date](https://github.com/calogica/dbt-date) as it is no longer actively maintained.
- To maintain functionality, the highly leveraged `dbt_date.convert_timezone` macro (see [README](https://github.com/fivetran/dbt_shopify_source?tab=readme-ov-file#step-5-setting-your-timezone) for how to use) has been replicated within the `macros/fivetran_date_macros` folder with minimal modifications. It has been prefixed with `fivetran_` to avoid potential naming conflicts:
  - `dbt_date.convert_timezone` -> `shopify_source.fivetran_convert_timezone`

# dbt_shopify_source v0.16.0  
[PR #97](https://github.com/fivetran/dbt_shopify_source/pull/97) includes the following updates:  

## Breaking Changes  
- Introduced the `inventory_quantity` source and the `stg_shopify__inventory_quantity` model to support downstream inventory quantity tracking. See the [documentation](https://fivetran.github.io/dbt_shopify_source/#!/model/model.shopify_source.stg_shopify__inventory_quantity) for details on the newly added columns.
  - This replaces the deprecated `available_quantity` column in `stg_shopify__inventory_level`.  

## Documentation  
- Added definitions for `inventory_quantity` and `stg_shopify__inventory_quantity`.  

## Under the Hood  
- Added seed `inventory_quantity_data` and macro `get_inventory_quantity_columns` to support the new `inventory_quantity` source.  

# dbt_shopify_source v0.15.0
This release includes the following updates:

## Under the Hood 
- (Affects Redshift only) Creates new `shopify_union_data` macro to accommodate Redshift's treatment of empty tables. ([PR #95](https://github.com/fivetran/dbt_shopify_source/pull/95))
  - For each staging model, if the source table is not found in any of your schemas, the package will create a table with one row with null values for Redshift destinations. There will be no change in behavior in non-Redshift warehouses.
  - This is necessary as Redshift will ignore explicit data casts when a table is completely empty and materialize every column as a `varchar`. This throws errors in downstream transformations in the `shopify` package. The 1 row will ensure that Redshift will respect the package's datatype casts.

## Documentation
- Corrected references to connectors and connections in the README. ([#94](https://github.com/fivetran/dbt_shopify_source/pull/94))

# dbt_shopify_source v0.14.0
[PR #93](https://github.com/fivetran/dbt_shopify_source/pull/93) includes the following changes:

## Breaking Changes
- Updated for connector changes released on January 6, 2025. See the [release notes](https://fivetran.com/docs/connectors/applications/shopify/changelog#january2025) for more details. Added the following columns to the `stg_shopify__*` staging tables:
  - `inventory_item`:
    - `duplicate_sku_count`
    - `harmonized_system_code`
    - `inventory_history_url`
    - `legacy_resource_id`
    - `measurement_id`
    - `measurement_weight_value`
    - `measurement_weight_unit`
    - `is_tracked_editable_locked`
    - `tracked_editable_reason`
    - `unit_cost_amount`
    - `unit_cost_currency_code`
  - `inventory_level`:
    - `inventory_level_id`
    - `can_deactivate`
    - `created_at`
    - `deactivation_alert`
  - `product_variant`:
    - `is_available_for_sale`
    - `display_name`
    - `legacy_resource_id`
    - `has_components_required`
    - `sellable_online_quantity`
  - `product_image`:
    - `media_id`
    - `status`
    - `url`

- For backward compatibility, the following columns were coalesced to combine values from the old column name with the new column name, with the resulting column retaining the new name:
  - `inventory_item`:
    - The deprecated `cost` column is coalesced with the new column `unit_cost_amount` as `unit_cost_amount`.
  - `product_image`:
    - The deprecated `src` column is coalesced with the new column `url` as `url`.

- Marked the following columns as deprecated in the documentation. These columns will return `null` values following the connector update, and customers should expect this behavior until the columns are fully removed in a future release.
  - `inventory_level`:
    - `available_quantity`
  - `product_variant`:
    - `fulfillment_service`
    - `grams`
    - `inventory_management`
    - `requires_shipping`
    - `weight`
    - `weight_unit`
    - `option_*`
  - `product_image`:
    - `position`
    - `created_at`
    - `updated_at`
    - `variant_ids`

## Under the Hood
- Updated `shopify_*_data` seed data and `get_*_columns` macros to include new columns for the following tables:
  - `inventory_item`
  - `inventory_level`
  - `product_image`
  - `product_variant`
- Standardized boolean casting by updating `get_*_columns` to use `dbt.type_boolean()` for consistency.


# dbt_shopify_source v0.13.0

[PR #91](https://github.com/fivetran/dbt_shopify_source/pull/91) includes the following changes:
## Breaking Changes
- Adds enable/disable config for the `metadata` staging model using the `shopify_using_metafield` variable (default `true`).
- Adds enable/disable config for the `abandoned_checkout` staging models using the `shopify_using_abandoned_checkout` variable (default `true`):
   - `stg_shopify__abandoned_checkout`
   - `stg_shopify__abandoned_checkout_discount_code`
   - `stg_shopify__abandoned_checkout_shipping_line`
- For more information on how to enable/disable these tables, refer to the [README](https://github.com/fivetran/dbt_shopify_source/blob/main/README.md#step-4-disable-models-for-non-existent-sources). This will be a breaking change if you choose to disable these tables.

## Under the Hood
- Updates the `index` calculation in `stg_shopify__abandoned_checkout_discount_code` by removing the conditional logic for null scenarios now that a disable config has been added to the model.

# dbt_shopify_source v0.12.1

## 🪲 Bug Fixes 🪛
- Added support for a new `delayed` fulfillment event status from Shopify. `delayed` has been added to the `accepted_values` test on `stg_shopify__fulfillment_event` ([PR #84](https://github.com/fivetran/dbt_shopify_source/pull/84)).
- Added `product_id` to the unique `combination_of_columns` test for the `stg_shopify__product_image` model ([PR #86](https://github.com/fivetran/dbt_shopify_source/pull/86)).

## Contributors
- [@ryan-brainforge](https://github.com/ryan-brainforge) ([PR #86](https://github.com/fivetran/dbt_shopify_source/pull/86))
- [@shreveasaurus](https://github.com/shreveasaurus) ([PR #84](https://github.com/fivetran/dbt_shopify_source/pull/84))

# dbt_shopify_source v0.12.0

[PR #79](https://github.com/fivetran/dbt_shopify_source/pull/79) introduces the following changes: 
## 🚨 Breaking Changes 🚨
- To reduce storage, updated default materialization of staging models from tables to views. 
  - Note that `stg_shopify__metafield` will still be materialized as a table for downstream use.
>  ⚠️ Running a `--full-refresh` will be required if you have previously run these staging models as tables and get the following error: 
> ```
> Trying to create view <model path> but it currently exists as a table. Either drop <model path> manually, or run dbt with `--full-refresh` and dbt will drop it for you.
> ```

## Under the Hood
- Updated the maintainer PR template to the current format.
- Added integration testing pipeline for Databricks SQL Warehouse.

[PR #81](https://github.com/fivetran/dbt_shopify_source/pull/81) introduces the following changes: 
## 🪲 Bug Fixes 🪛
- Removed the `index` filter in `stg_shopify__order_discount_code`, as we were erroneously filtering out multiple discounts for an order since `index` is meant to pair with `order_id` as the unique identifier for this source.
- Added `index` as a field in `stg_shopify__order_discount_code`, as it is part of the primary key.

## 📝 Documentation Updates 📝
- Added `index` documentation to our `src_shopify.yml` and `stg_shopify.yml`.
- Updated the `unique_combination_of_columns` test on `stg_shopify__order_discount_code` to correctly check on `index` with `order_id` and `source_relation` rather than `code`.

## 🔧 Under the Hood 🔩
- Updated the pull request templates.

# dbt_shopify_source v0.11.0
[PR #78](https://github.com/fivetran/dbt_shopify_source/pull/78) introduces the following changes: 

## 🚨 Breaking Changes 🚨
- Added `source_relation` to the `partition_by` clauses that determine the `is_most_recent_record` in the `stg_shopify__metafield` table.
- Added `source_relation` to the `partition_by` clauses that determines the `index` in the `stg_shopify__abandoned_checkout_discount_code` table. 
- If the user is leveraging the union feature, this could change data values.

## 🐛 Bug Fixes 🪛 
- Updated partition logic in `stg_shopify__metafield` and `stg_shopify__abandoned_checkout_discount_code` to account for null table Redshift errors when handling null field cases. 

## 🚘 Under The Hood 🚘
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Added additional casting in seed dependencies for above models `integration_tests/dbt_project.yml` to ensure local testing passed on null cases.

# dbt_shopify_source v0.10.0
## 🚨 Breaking Changes 🚨
- This release will be a breaking change due to the removal of below dependencies.
## Dependency Updates
- Removes the dependency on [dbt-expectations](https://github.com/calogica/dbt-expectations/releases) and updates the [dbt-date](https://github.com/calogica/dbt-date/releases) dependency to the latest version. ([PR #75](https://github.com/fivetran/dbt_shopify_source/pull/75))

# dbt_shopify_source v0.9.0
## Breaking Changes
- In [June 2023](https://fivetran.com/docs/applications/shopify/changelog#june2023) the Shopify connector received an update which upgraded the connector to be compatible with the new [2023-04 Shopify API](https://shopify.dev/docs/api). As a result, the following fields have been removed as they were deprecated in the API upgrade: ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

| **model** | **field removed** |
|-------|--------------|
| [stg_shopify__customer](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__customer) | `lifetime_duration` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `fulfillment_service` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `destination_location_*` fields |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `origin_location_*` fields |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `total_price_usd` |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `processing_method` |

## Under the Hood
- Removed `databricks` from the shopify_database configuration in the `src_shopify.yml` to allow Databricks Unity catalog users to define a unity Catalog as a database. ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

## Documentation Updates
- Documentation provided in the README for how to connect sources when leveraging the union schema/database feature. ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

# dbt_shopify_source v0.8.3

## Bug Fixes 🐛 🪛 
[PR #69](https://github.com/fivetran/dbt_shopify_source/pull/69) includes the following fixes:
- Lower casing `metafield_reference` field in `stg_shopify__metafield` to fix metafield table breakages upstream when the `key` field has different casing for otherwise identical strings.
- Lower casing `owner_resource` field in `stg_shopify__metafield` to ensure identical `value` fields with different casing are then correctly pivoted together upstream in the shopify transformation package `get_metafields` macro. 
 
## Contributors
- [@ZCrookston](https://github.com/ZCrookston) & [@FridayPush](https://github.com/FridayPush) ([Issue #64](https://github.com/fivetran/dbt_shopify_source/issues/64))

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([PR #65](https://github.com/fivetran/dbt_shopify_source/pull/65/files))
- Updated the pull request [templates](/.github). ([PR #65](https://github.com/fivetran/dbt_shopify_source/pull/65/files))

# dbt_shopify_source v0.8.2

## Bug Fixes
[PR #59](https://github.com/fivetran/dbt_shopify_source/pull/59) introduces the following changes:
- The `fivetan_utils.union_data` [macro](https://github.com/fivetran/dbt_fivetran_utils/pull/100) has been expanded to handle checking if a source table exists. Previously in the Shopify source package, this check happened outside of the macro and depended on the user having a defined shopify `source`. If the package anticipates a table that you do not have in any schema or database, it will return a **completely** empty table (ie `limit 0`) that will work seamlessly with downstream transformations.
  - A compilation message will be raised when a staging model is completely empty. This compiler warning can be turned off by the end user by setting the `fivetran__remove_empty_table_warnings` variable to `True` (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).
- A uniqueness test has been placed on the `order_line_id`, `index`, and `source_relation` columns in `stg_shopify__tax_line`, as it was previously missing a uniqueness test.

## Contributors
- [@dfagnan](https://github.com/dfagnan) (Issue https://github.com/fivetran/dbt_shopify_source/issues/57)

# dbt_shopify_source v0.8.1

## Bug Fixes
- Addresses [Issue #54](https://github.com/fivetran/dbt_shopify_source/issues/54), in which the deprecated `discount_id` field was used instead of `code` in `stg_shopify__abandoned_checkout_discount__code` ([PR #56](https://github.com/fivetran/dbt_shopify_source/pull/56)).

# dbt_shopify_source v0.8.0

Lots of new features ahead!! We've revamped the package to keep up-to-date with new additions to the Shopify connector and feedback from the community. 

This release includes 🚨 **Breaking Changes** 🚨.

## Documentation
- Created the [DECISIONLOG](https://github.com/fivetran/dbt_shopify_source/blob/main/DECISIONLOG.md) to log discussions and opinionated stances we took in designing the package ([PR #45](https://github.com/fivetran/dbt_shopify_source/pull/45)).
- README updated for easier package use and navigation ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).

## Under the Hood 
- Ensured Postgres compatibility ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).
- Got rid of the `shopify__using_order_adjustment`, `shopify__using_order_line_refund`, and `shopify__using_refund` variables. Instead, the package will automatically create empty versions of the related models until the source `refund`, `order_line_refund`, and `order_adjustment` tables exist in your schema. See DECISIONLOG for more details ([PR #45](https://github.com/fivetran/dbt_shopify_source/pull/45)).
- Adjusts the organization of the `get_<table>_columns()` macros ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39), [PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)).

## Feature Updates
- Addition of the `shopify_timezone` variable, which converts ALL timestamps included in the package (including `_fivetran_synced`) to a single target timezone in IANA Database format, ie "America/Los_Angeles" ([PR #41](https://github.com/fivetran/dbt_shopify_source/pull/41)).
- `shopify_<default_source_table_name>_identifier` variables added if an individual source table has a different name than the package expects ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).
- The declaration of passthrough variables within your root `dbt_project.yml` has changed (but is backwards compatible). To allow for more flexibility and better tracking of passthrough columns, you will now want to define passthrough columns in the following format ([PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
> This applies to all passthrough columns within the `dbt_shopify_source` package and not just the `customer_pass_through_columns` example. See the README for which models have passthrough columns.
```yml
vars:
  customer_pass_through_columns:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
      transform_sql: "cast(field_alias as string)" # Optional: If you wish to define the datatype or apply a light transformation.
```
- The following fields have been added to (➕) or removed from (➖) their respective staging models ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39), [PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
  - `stg_shopify__order`:
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
  - `stg_shopify__customer`:
    - ➕ `note`
    - ➕ `lifetime_duration`
    - ➕ `currency`
    - ➕ `marketing_consent_state` (coalescing of `email_marketing_consent_state` and deprecated `accepts_marketing` field)
    - ➕ `marketing_opt_in_level` (coalescing of `email_marketing_consent_opt_in_level` and deprecated `marketing_opt_in_level` field)
    - ➕ `marketing_consent_updated_at` (coalescing of `email_marketing_consent_consent_updated_at` and deprecated `accepts_marketing_updated_at` field)
    - ➖ `accepts_marketing`/`has_accepted_marketing`
    - ➖ `accepts_marketing_updated_at`
    - ➖ `marketing_opt_in_level`
  - `stg_shopify__order_line_refund`:
    - ➕ `subtotal_set`
    - ➕ `total_tax_set`
  - `stg_shopify__order_line`:
    - ➕ `pre_tax_price_set`
    - ➕ `price_set`
    - ➕ `tax_code`
    - ➕ `total_discount_set`
    - ➕ `variant_title`
    - ➕ `variant_inventory_management`
    - ➕ `properties`
    - ( ) `is_requiring_shipping` is renamed to `is_shipping_required`
  - `stg_shopify__product`:
    - ➕ `status`
  - `stg_shopify__product_variant`
    - ➖ `old_inventory_quantity` -> coalesced with `inventory_quantity`
    - ➕ `inventory_quantity` -> coalesced with `old_inventory_quantity`
- The following source tables have been added to the package with respective staging models ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39)):
  - `abandoned_checkout`
  - `collection_product`
  - `collection`
  - `customer_tag`
  - `discount_code` -> if the table does not exist in your schema, the package will create an empty staging model and reference that ([PR #47](https://github.com/fivetran/dbt_shopify_source/pull/47/files), see [DECISIONLOG](https://github.com/fivetran/dbt_shopify/blob/main/DECISIONLOG.md))
  - `fulfillment`
  - `inventory_item`
  - `inventory_level`
  - `location`
  - `metafield` ([#PR 49](https://github.com/fivetran/dbt_shopify_source/pull/49) as well)
  - `order_note_attribute`
  - `order_shipping_line`
  - `order_shipping_tax_line`
  - `order_tag`
  - `order_url_tag`
  - `price_rule`
  - `product_image`
  - `product_tag`
  - `shop`
  - `tender_transaction`
  - `abandoned_checkout_discount_code`
  - `order_discount_code`
  - `tax_line`
  - `abandoned_checkout_shipping_line` ([(PR #47)](https://github.com/fivetran/dbt_shopify_source/pull/47) as well)
  - `fulfillment_event` -> This is NOT included by default. To include fulfillment events (used in the `shopify__daily_shop` model), set the `shopify_using_fulfillment_event` variable to `true` ([PR #48](https://github.com/fivetran/dbt_shopify_source/pull/48))

# dbt_shopify_source v0.7.0
## 🚨 Breaking Changes 🚨:
[PR #36](https://github.com/fivetran/dbt_shopify_source/pull/36) includes the following breaking changes:
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

# dbt_shopify_source v0.6.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

- The `union_schemas` and `union_databases` variables have been replaced with `shopify_union_schemas` and `shopify_union_databases` respectively. This allows for multiple packages with the union ability to be used and not locked to a single variable that is used across packages.

# dbt_shopify_source v0.5.2
## Under the Hood
- Rearranged the ordering of the columns within the `get_order_columns` macro. This ensure the output of the models within the downstream [Shopify Holistic Reporting](https://github.com/fivetran/dbt_shopify_holistic_reporting) package are easier to understand and interpret. ([#29](https://github.com/fivetran/dbt_shopify_source/pull/29))

# dbt_shopify_source v0.1.0 -> v0.5.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
