{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with fulfillment as (

    select *
    from {{ var('shopify_gql_fulfillment') }}
),

agg_fulfillment_services as (
    
    select 
        fulfillment_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(service as " ~ dbt.type_string() ~ ")", "', '") }} as fulfillment_services
    from fulfillment
    group by fulfillment_id, source_relation
),

fulfillment_prep as (

    select 
        fulfillment.*,
        agg_fulfillment_services.fulfillment_services
    from fulfillment
    left join agg_fulfillment_services
        on fulfillment.fulfillment_id = agg_fulfillment_services.fulfillment_id
        and fulfillment.source_relation = agg_fulfillment_services.source_relation
)

{% if var('shopify_gql_using_fulfillment_tracking_info', False) %}
, fulfillment_tracking_info as (

    select *
    from {{ var('shopify_gql_fulfillment_tracking_info') }}
),

agg_fulfillment_tracking_info as (

    select 
        fulfillment_id,
        source_relation,
        {{ fivetran_utils.string_agg("distinct cast(tracking_number as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_numbers,
        {{ fivetran_utils.string_agg("distinct cast(tracking_url as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_urls,
        {{ fivetran_utils.string_agg("distinct cast(tracking_company as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_companies
    from fulfillment_tracking_info
    group by fulfillment_id, source_relation
),

joined as (

    select 
        fulfillment_prep.*,
        agg_fulfillment_tracking_info.tracking_numbers,
        agg_fulfillment_tracking_info.tracking_urls,
        agg_fulfillment_tracking_info.tracking_companies
    from fulfillment_prep
    left join agg_fulfillment_tracking_info
        on fulfillment_prep.fulfillment_id = agg_fulfillment_tracking_info.fulfillment_id
        and fulfillment_prep.source_relation = agg_fulfillment_tracking_info.source_relation
)

select *
from joined
{% else %}

select 
    fulfillment_prep.*,
    cast(null as {{ dbt.type_string() }}) as tracking_numbers,
    cast(null as {{ dbt.type_string() }}) as tracking_urls,
    cast(null as {{ dbt.type_string() }}) as tracking_companies
from fulfillment_prep
{% endif %}