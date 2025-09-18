{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with collection as (

    select *
    from {{ ref('stg_shopify_gql__collection') }}
)

{% if var('shopify_gql_using_collection_rule', False) %}
, collection_rule as (

    select *
    from {{ ref('stg_shopify_gql__collection_rule') }}
),

prep_collection_rule as (

    select 
        collection_id,
        source_relation,
        '{"column":"' || columns || '","relation":"' || relation || '","condition":"' || condition || '"}' as rule
    from collection_rule
),

agg_collection_rule as (
    
    select 
        collection_id,
        source_relation,
        '[' || {{ fivetran_utils.string_agg("rule", "','") }} || ']' as rules
    from prep_collection_rule
    group by 1,2
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

{% else %}
select 
    collection.*,
    cast(null as {{ dbt.type_string() }}) as rules
from collection

{% endif %}