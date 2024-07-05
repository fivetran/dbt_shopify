{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

-- this test is to make sure there is no fanout between the spine and the daily_overview
with stg_invoice_line_item as (
    select count(*) as line_item_count
    from {{ target.schema }}_shopify_dev.stg_shopify__order_line
),

line_item_enhanced as (
    select count(*) as daily_overview_count
    from {{ target.schema }}_shopify_dev.shopify__line_item_enhanced
)

-- test will return values and fail if the row counts don't match
select *
from stg_invoice_line_item
join line_item_enhanced
    on stg_invoice_line_item.line_item_count != line_item_enhanced.daily_overview_count