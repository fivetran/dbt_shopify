{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with source as (
    select
        count(*) as source_count
    from {{ target.schema }}_shopify_dev.stg_shopify__inventory_level as il
    join {{ target.schema }}_shopify_dev.stg_shopify__inventory_item as ii
        on il.inventory_item_id = ii.inventory_item_id 
        and il.source_relation = ii.source_relation 
    join {{ target.schema }}_shopify_dev.stg_shopify__location as lo
        on il.location_id = lo.location_id 
        and il.source_relation = lo.source_relation 
    join {{ target.schema }}_shopify_dev.stg_shopify__product_variant as pv
        on il.inventory_item_id = pv.inventory_item_id
        and il.source_relation = pv.source_relation
),

transform as (
    select
        count(*) as transform_count
    from {{ target.schema }}_shopify_dev.shopify__inventory_levels
), 

compare as (
    select *
    from source
    cross join transform
)

select *
from compare
where source_count != transform_count