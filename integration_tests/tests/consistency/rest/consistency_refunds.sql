{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('shopify_api', 'rest') == 'rest'
) }}

{% set exclude_cols = ['pre_tax_price_set', 'price_set', 'total_discount_set', 'properties'] + var('consistency_test_exclude_metrics', []) %}

-- this test ensures the shopify__refunds end model matches the prior version
with prod as (
    select {{ dbt_utils.star(from=ref('shopify__refunds'), except=exclude_cols) }}
    from {{ target.schema }}_shopify_prod.shopify__refunds
),

dev as (
    select {{ dbt_utils.star(from=ref('shopify__refunds'), except=exclude_cols) }}
    from {{ target.schema }}_shopify_dev.shopify__refunds
), 

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final