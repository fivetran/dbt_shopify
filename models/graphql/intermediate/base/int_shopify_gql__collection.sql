{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with collection as (

    select *
    from {{ var('shopify_gql_collection') }}
),

collection_rule as (

    select *
    from {{ var('shopify_gql_collection_rule') }}
),

prep_collection_rule as (

    select 
        collection_id,
        source_relation,
        {# should we lower() these fields? #}
        '{"column":"' || columns || '","relation":"' || relation || '","condition":"' || condition || '"}' as rule
    from collection_rule
),

agg_collection_rule as (
    
    select 
        collection_id,
        source_relation,
        '[' || {{ fivetran_utils.string_agg("rule", "','") }} || ']' as rules
    from prep_collection_rule
    group by collection_id, source_relation
),

joined as (

    select 
        collection.*,
        agg_collection_rule.rules
    from collection
    left join agg_collection_rule
        on collection.collection_id = agg_collection_rule.collection_id
        and collection.source_relation = agg_collection_rule.source_relation
)

select *
from joined