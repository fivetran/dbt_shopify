{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('shopify_api', 'rest') == 'graphql' and var('shopify_gql_using_metafield', True)
) }}

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
