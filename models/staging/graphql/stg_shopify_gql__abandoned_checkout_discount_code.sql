{{ config(enabled=(var('shopify_gql_using_abandoned_checkout', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__abandoned_checkout_discount_code_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__abandoned_checkout_discount_code_tmp')),
                staging_columns=get_graphql_abandoned_checkout_discount_code_columns()
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
        checkout_id,
        upper(code) as code,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation, 
        row_number() over(partition by checkout_id, upper(code), source_relation order by index desc) as index,
        {{ dbt_utils.generate_surrogate_key(['checkout_id', 'code', 'source_relation']) }} as unique_key

    from fields

)

select *
from final
where index = 1
