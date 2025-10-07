# Multi-Tenant E-commerce Data Transformation

This dbt project transforms raw e-commerce data from Airbyte into analytics-ready datasets for multiple platforms (Shopify, Salla) and multiple stores.

## Architecture

### Three-Layer Design
1. **Staging Layer** - Views that clean, flatten, and standardize raw JSON data from Airbyte
2. **Intermediate Layer** - Ephemeral models for reusable aggregations
3. **Marts Layer** - Final business-ready tables for analytics

### Multi-Tenant Structure

Each store gets its own set of datasets:

**Pattern:** `{platform}_{store}_{environment}_{layer}`

**Example for Shopify store "worood" in test environment:**
- Raw source: `shopify_worood`
- Staging: `shopify_worood_test_stg_shopify`
- Marts: `shopify_worood_test_airshopify`

**Example for Salla store "demo" in test environment:**
- Raw source: `salla_demo`
- Staging: `salla_demo_test_stg_salla`
- Marts: `salla_demo_test_airsalla`

## Available Models

### Shopify Models

**Staging Models** (14 models in `models/staging/`)
- `stg_shopify__customer` - Customer records
- `stg_shopify__order` - Order headers
- `stg_shopify__order_line` - Order line items
- `stg_shopify__product` - Products
- `stg_shopify__product_variant` - Product variants
- `stg_shopify__product_tag` - Product tags (unnested)
- `stg_shopify__collection` - Collections
- `stg_shopify__inventory_level` - Inventory at locations
- `stg_shopify__location` - Store locations
- `stg_shopify__order_shipping_line` - Shipping details
- `stg_shopify__order_discount_code` - Applied discount codes
- `stg_shopify__abandoned_checkout` - Abandoned carts
- `stg_shopify__fulfillment` - Order fulfillments
- `stg_shopify__refund` - Refunds

**Intermediate Models** (3 models in `models/intermediate/`)
- `int_shopify__customer_email_rollup` - Email deduplication
- `int_shopify__product__order_line_aggregates` - Product sales aggregates
- `int_shopify__customers__order_aggregates` - Customer purchase aggregates

**Marts** (8 models in `models/marts/`)
- `customers` - Customer analytics with lifetime metrics
- `orders` - Order-level analytics
- `order_lines` - Line item details with product info
- `products` - Product performance metrics
- `inventory_levels` - Current inventory status
- `discounts` - Discount usage and performance
- `customer_cohorts` - Customer cohort analysis by ID
- `customer_email_cohorts` - Customer cohort analysis by email

**Utils** (1 model in `models/utils/`)
- `calendar` - Date dimension table

### Salla Models

**Staging Models** (14 models in `models/salla_staging/`)
- `stg_salla__customer` - Customer records
- `stg_salla__order` - Order headers
- `stg_salla__order_item` - Order line items
- `stg_salla__product` - Products
- `stg_salla__product_variant` - Product variants
- `stg_salla__transaction` - Payment transactions
- `stg_salla__coupon` - Coupon definitions
- `stg_salla__coupon_code` - Individual coupon codes
- `stg_salla__abandoned_cart` - Abandoned carts
- `stg_salla__order_shipment` - Shipment tracking
- `stg_salla__order_history` - Order status history
- `stg_salla__product_quantity` - Product quantity history
- `stg_salla__brand` - Product brands
- `stg_salla__category` - Product categories

**Intermediate Models** (3 models in `models/salla_intermediate/`)
- `int_salla__customer_email_rollup` - Email deduplication
- `int_salla__order__line_aggregates` - Order aggregates
- `salla__customers__order_aggregates` - Customer purchase aggregates

**Marts** (7 models in `models/salla_marts/`)
- `salla_customers` - Customer analytics
- `salla_orders` - Order-level analytics
- `salla_order_lines` - Line item details
- `salla_products` - Product performance
- `salla_transactions` - Payment transaction history
- `salla_customer_cohorts` - Customer cohort analysis by ID
- `salla_customer_email_cohorts` - Customer cohort analysis by email

**Utils** (1 model in `models/salla_utils/`)
- `salla_calendar` - Date dimension table

## Adding a New Store

### Step 1: Set Up Airbyte Connection

Ensure your Airbyte connection creates a dataset following the naming pattern:
- Shopify: `shopify_{store_name}`
- Salla: `salla_{store_name}`

Example: `shopify_store2`, `salla_store2`

### Step 2: Add Profile Configuration

Edit `profiles.yml` and add a new target:

```yaml
wow_ai_transformation:
  outputs:
    # Existing stores...

    {platform}_{store_name}_dev:
      dataset: {platform}_{store_name}_test
      location: EU
      method: oauth
      project: wow-ai-461911

    {platform}_{store_name}_prod:
      dataset: {platform}_{store_name}
      location: EU
      method: oauth
      project: wow-ai-461911
```

**Example for new Shopify store "store2":**
```yaml
    shopify_store2_dev:
      dataset: shopify_store2_test
      location: EU
      method: oauth
      project: wow-ai-461911
```

### Step 3: Add Source Configuration

For **Shopify stores**, add to `models/staging/sources.yml`:

```yaml
  - name: shopify_{store_name}_raw
    database: wow-ai-461911
    schema: shopify_{store_name}
    quoting:
      database: true
      schema: true
      identifier: true
    tables:
      - name: customers
      - name: orders
      # ... (copy all table names from shopify_raw source)
```

For **Salla stores**, add to `models/salla_staging/sources.yml`:

```yaml
  - name: salla_{store_name}_raw
    database: wow-ai-461911
    schema: salla_{store_name}
    quoting:
      database: true
      schema: true
      identifier: true
    tables:
      - name: customers
      - name: orders
      # ... (copy all table names from salla_raw source)
```

### Step 4: Update Models to Reference New Source

**For Shopify:**
- Copy existing staging models to new folder or update source references
- Change `{{ source('shopify_raw', 'table_name') }}` to `{{ source('shopify_{store_name}_raw', 'table_name') }}`

**For Salla:**
- Copy existing staging models or update source references
- Change `{{ source('salla_raw', 'table_name') }}` to `{{ source('salla_{store_name}_raw', 'table_name') }}`

### Step 5: Run Transformations

```bash
# Test environment
dbt run --target {platform}_{store_name}_dev

# Production environment
dbt run --target {platform}_{store_name}_prod
```

## Running Transformations

### Run All Models for Specific Store

```bash
# Shopify worood store (dev)
dbt run --target shopify_worood_dev

# Salla demo store (dev)
dbt run --target salla_demo_dev
```

### Run Specific Layer

```bash
# Staging only
dbt run --target shopify_worood_dev --select staging

# Marts only
dbt run --target shopify_worood_dev --select marts
```

### Run Specific Model

```bash
dbt run --target shopify_worood_dev --select customers
dbt run --target salla_demo_dev --select salla_customers
```

### Compile Only (No Materialization)

```bash
dbt compile --target shopify_worood_dev
dbt compile --target salla_demo_dev
```

## Dataset Naming Convention

| Component | Pattern | Example (Shopify) | Example (Salla) |
|-----------|---------|-------------------|-----------------|
| Raw source | `{platform}_{store}` | `shopify_worood` | `salla_demo` |
| Staging (dev) | `{platform}_{store}_test_stg_{platform}` | `shopify_worood_test_stg_shopify` | `salla_demo_test_stg_salla` |
| Marts (dev) | `{platform}_{store}_test_air{platform}` | `shopify_worood_test_airshopify` | `salla_demo_test_airsalla` |
| Staging (prod) | `{platform}_{store}_stg_{platform}` | `shopify_worood_stg_shopify` | `salla_demo_stg_salla` |
| Marts (prod) | `{platform}_{store}_air{platform}` | `shopify_worood_airshopify` | `salla_demo_airsalla` |

## Project Configuration

### Key Files

- **[dbt_project.yml](dbt_project.yml)** - Project configuration, schema definitions, materialization settings
- **[profiles.yml](profiles.yml)** - BigQuery connection profiles for each store
- **[packages.yml](packages.yml)** - dbt package dependencies (dbt_utils)

### Materialization Strategy

- **Staging**: Materialized as `view` (always fresh, no storage cost)
- **Intermediate**: Materialized as `ephemeral` (compiled inline, not materialized)
- **Marts**: Materialized as `table` (fast query performance)
- **Utils**: Materialized as `table` (calendar/dimension tables)

### Schema on Run Start

The project automatically creates required schemas when running:
- `{dataset}_stg_shopify` for Shopify staging
- `{dataset}_airshopify` for Shopify marts
- `{dataset}_stg_salla` for Salla staging
- `{dataset}_airsalla` for Salla marts

## Technical Notes

### BigQuery Specific

- All datasets must be in **EU** region
- Project ID `wow-ai-461911` contains dashes, requires quoting enabled
- Uses OAuth authentication method

### Airbyte Data Structure

- Airbyte preserves nested JSON structures (unlike Fivetran which flattens)
- Staging models handle JSON extraction using `json_extract_scalar()` and `json_extract_array()`
- Arrays are unnested using `unnest()` function
- Timestamp fields are parsed with `parse_timestamp()` or cast from strings

### Data Quality

- No `cast(null as type)` placeholder columns in marts
- Only computed/available fields are included
- Surrogate keys generated using `dbt_utils.generate_surrogate_key()`
- All timestamps preserved as `timestamp` type
- Dates cast to `date` type for cohort analysis

## Current Stores

| Platform | Store Name | Target (Dev) | Raw Dataset | Staging Dataset | Marts Dataset |
|----------|-----------|--------------|-------------|-----------------|---------------|
| Shopify | worood | `shopify_worood_dev` | `shopify_worood` | `shopify_worood_test_stg_shopify` | `shopify_worood_test_airshopify` |
| Salla | demo | `salla_demo_dev` | `salla_demo` | `salla_demo_test_stg_salla` | `salla_demo_test_airsalla` |

## Dependencies

- dbt-core >= 1.3.0, < 2.0.0
- dbt-bigquery 1.9.2
- dbt_utils 1.3.1
