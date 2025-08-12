{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with fulfillment as (

    select *
    from {{ ref('stg_shopify_gql__fulfillment') }}
),

count_fulfillments as (
    -- necessary to split out as Redshift does not support string_agg and count(distinct) in the same query
    select 
        order_id,
        source_relation,
        count(distinct fulfillment_id) as number_of_fulfillments

    from fulfillment
    group by 1,2
),

{% if var('shopify_gql_using_fulfillment_tracking_info', False) %}
fulfillment_tracking_info as (

    select *
    from {{ ref('stg_shopify_gql__fulfillment_tracking_info') }}
),

joined as (

    select 
        fulfillment.order_id,
        fulfillment.source_relation,
        {{ fivetran_utils.string_agg("distinct cast(fulfillment_tracking_info.tracking_number as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_numbers,
        {{ fivetran_utils.string_agg("distinct cast(fulfillment_tracking_info.tracking_url as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_urls,
        {{ fivetran_utils.string_agg("distinct cast(fulfillment_tracking_info.tracking_company as " ~ dbt.type_string() ~ ")", "', '") }} as tracking_companies,
        {{ fivetran_utils.string_agg("distinct cast(fulfillment.service as " ~ dbt.type_string() ~ ")", "', '") }} as fulfillment_services
    from fulfillment 
    left join fulfillment_tracking_info
        on fulfillment.fulfillment_id = fulfillment_tracking_info.fulfillment_id
        and fulfillment.source_relation = fulfillment_tracking_info.source_relation
    group by 1,2
),

final as (

    select 
        joined.order_id,
        joined.source_relation,
        joined.tracking_numbers,
        joined.tracking_urls,
        joined.tracking_companies,
        joined.fulfillment_services,
        count_fulfillments.number_of_fulfillments
    from joined
    left join count_fulfillments
        on joined.order_id = count_fulfillments.order_id
        and joined.source_relation = count_fulfillments.source_relation
)

{% else %}
final as (

    select 
        fulfillment.order_id,
        fulfillment.source_relation,
        count_fulfillments.number_of_fulfillments,
        max(cast(null as {{ dbt.type_string() }})) as tracking_numbers,
        max(cast(null as {{ dbt.type_string() }})) as tracking_urls,
        max(cast(null as {{ dbt.type_string() }})) as tracking_companies,
        {{ fivetran_utils.string_agg("distinct cast(fulfillment.service as " ~ dbt.type_string() ~ ")", "', '") }} as fulfillment_services
        
    from fulfillment
    left join count_fulfillments
        on fulfillment.order_id = count_fulfillments.order_id
        and fulfillment.source_relation = count_fulfillments.source_relation
    group by 1,2,3
)
{% endif %}

select *
from final