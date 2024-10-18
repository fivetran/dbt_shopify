{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with source as (
    select
        customer_id,
        count(*) as source_customer_tag_count
    from {{ target.schema }}_shopify_dev.stg_shopify__customer_tag
    group by 1
),

transform as (
    select
        customer_id,
        count(*) as transform_customer_tag_count
    from {{ target.schema }}_shopify_dev.shopify__customers
    where customer_tags is not null
    group by 1
), 

compare as (
    select
        source.customer_id,
        source.source_customer_tag_count,
        transform.transform_customer_tag_count
    from source
    full outer join transform
    on source.customer_id = transform.customer_id
    where source.source_customer_tag_count != transform.transform_customer_tag_count
    )

select *
from compare