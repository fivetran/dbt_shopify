{{ config(enabled=(var('shopify_gql_using_customer_visit', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__customer_visit_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__customer_visit_tmp')),
                staging_columns=get_graphql_customer_visit_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}

    from base
),

final as (
    
    select 
        id as customer_visit_id,
        order_id,
        type,
        landing_page,
        landing_page_html,
        referral_code,
        referral_info_html,
        referrer_url as referring_site,
        source,
        source_description,
        source_type,
        utm_parameters_campaign,
        utm_parameters_content,
        utm_parameters_medium,
        utm_parameters_source,
        utm_parameters_term,
        {{ shopify.fivetran_convert_timezone(column='cast(occurred_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as occurred_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
