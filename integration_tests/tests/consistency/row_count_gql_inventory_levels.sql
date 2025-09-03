{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select *
    from {{ target.schema }}_shopify_prod.shopify_gql__inventory_levels
),

dev as (
    select *
    from {{ target.schema }}_shopify_dev.shopify_gql__inventory_levels
), 

prod_count as (
    select 
        count(*) as total_prod_rows
    from prod
),

dev_count as (
    select 
        count(*) as total_dev_rows
    from dev
),

final as (
    select
        total_prod_rows,
        total_dev_rows
    from prod_count
    cross join dev_count
)

select *
from final
where total_prod_rows != total_dev_rows