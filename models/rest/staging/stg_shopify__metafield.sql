{{ config(enabled=(var('shopify_using_metafield', True) and var('shopify_api', 'rest') == 'rest')) }}

with base as (

    select * 
    from {{ ref('stg_shopify__metafield_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__metafield_tmp')),
                staging_columns=get_metafield_columns()
            )
        }}

        {{ fivetran_utils.apply_source_relation(package_name='shopify') }}

    from base
),

final as (
    
    select 
        id as metafield_id,
        description,
        namespace,
        key,
        value,
        lower(coalesce(type, value_type)) as value_type,
        owner_id as owner_resource_id,
        lower(owner_resource) as owner_resource,
        {{ shopify.fivetran_convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        lower({{ dbt.concat(["namespace","'_'","key"]) }}) as metafield_reference,
        row_number() over(partition by id {{ fivetran_utils.partition_by_source_relation(package_name='shopify') }} order by updated_at desc) = 1 as is_most_recent_record,
        source_relation
        
    from fields
)

select *
from final