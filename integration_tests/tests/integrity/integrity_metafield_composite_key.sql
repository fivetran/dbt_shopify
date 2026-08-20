{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('shopify_api', 'rest') == 'graphql' and var('shopify_gql_using_metafield', True)
) }}

-- Confirms the composite-key dedup in stg_shopify_gql__metafield (partitioned on
-- id, owner_id, owner_resource) does not error or regress: every group should
-- resolve to exactly one most-recent row, and no two most-recent rows should
-- collide on unique_key. A non-empty result means the dedup or surrogate key
-- logic is broken, not that the underlying data is wrong.

with stg as (

    select *
    from {{ target.schema }}_shopify_dev.stg_shopify_gql__metafield

),

duplicate_most_recent_groups as (

    select
        metafield_id,
        owner_resource_id,
        owner_resource,
        source_relation,
        count(*) as most_recent_row_count
    from stg
    where is_most_recent_record
    group by 1, 2, 3, 4
    having count(*) > 1
),

duplicate_unique_keys as (

    select
        unique_key,
        count(*) as unique_key_count
    from stg
    where is_most_recent_record
    group by 1
    having count(*) > 1
),

final as (

    select
        'duplicate_most_recent_groups' as failure_type,
        cast(metafield_id as {{ dbt.type_string() }}) as failing_value,
        most_recent_row_count as failure_count
    from duplicate_most_recent_groups

    union all

    select
        'duplicate_unique_keys' as failure_type,
        cast(unique_key as {{ dbt.type_string() }}) as failing_value,
        unique_key_count as failure_count
    from duplicate_unique_keys
)

select *
from final
