{{ config(enabled=(var('shopify_gql_using_fulfillment_tracking_info', False) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__fulfillment_tracking_info_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__fulfillment_tracking_info_tmp')),
                staging_columns=get_graphql_fulfillment_tracking_info_columns()
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
        fulfillment_id,
        index,
        company as tracking_company,
        number as tracking_number,
        url as tracking_url,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['fulfillment_id', 'index', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
