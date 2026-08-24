{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('shopify_api', 'rest') == 'graphql' and var('shopify_gql_using_metafield', True)
) }}

-- Confirms the composite-key fix actually works: two metafields that collide on
-- `id` alone (different owner_id/owner_resource) must BOTH survive as
-- is_most_recent_record = true. A regression to the old `partition by id`
-- dedup would silently drop one of them without tripping any duplicate-key
-- test, since it's a suppression bug, not a duplication bug -- so this checks
-- for the missing survivor directly rather than for accidental duplicates
-- (duplicate unique_key values are already covered by the `unique` test on
-- stg_shopify_gql__metafield.unique_key in stg_shopify_graphql.yml).

with stg as (

    select *
    from {{ target.schema }}_shopify_dev.stg_shopify_gql__metafield
    where metafield_id = 7003  -- seeded cross-entity collision: customer 1001 + order 4001

),

expected_survivors as (

    select 1001 as owner_resource_id, 'customer' as owner_resource
    union all
    select 4001, 'order'

),

final as (

    select
        expected_survivors.owner_resource_id,
        expected_survivors.owner_resource
    from expected_survivors
    left join stg
        on stg.owner_resource_id = expected_survivors.owner_resource_id
        and stg.owner_resource = expected_survivors.owner_resource
        and stg.is_most_recent_record
    where stg.metafield_id is null  -- expected survivor is missing

)

select *
from final
