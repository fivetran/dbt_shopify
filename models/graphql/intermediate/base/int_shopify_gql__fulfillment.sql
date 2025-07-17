{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with fulfillment as (

    select *
    from {{ var('shopify_gql_fulfillment') }}
),

fulfillment_tracking_info as (

    select *
    from {{ var('shopify_gql_fulfillment_tracking_info') }}
),

agg_fulfillment_tracking_info as (

    select 
        fulfillment_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(tracking_number as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_numbers,
        {{ fivetran_utils.string_agg("distinct cast(tracking_url as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_urls,
        {# QUESTION: This is new, should we include? #}
        {{ fivetran_utils.string_agg("distinct cast(tracking_company as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_companies
    from fulfillment_tracking_info
    group by fulfillment_id, source_relation
),

joined as (

    select 
        fulfillment.*,
        agg_fulfillment_tracking_info.tracking_numbers,
        agg_fulfillment_tracking_info.tracking_urls,
        agg_fulfillment_tracking_info.tracking_companies
    from fulfillment
    left join agg_fulfillment_tracking_info
        on fulfillment.fulfillment_id = agg_fulfillment_tracking_info.fulfillment_id
        and fulfillment.source_relation = agg_fulfillment_tracking_info.source_relation
)

select *
from joined