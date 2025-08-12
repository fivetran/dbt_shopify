{{ config(enabled=var('shopify_api', 'rest') == 'rest') }}

{% set source_columns_in_relation = adapter.get_columns_in_relation(ref('stg_shopify__collection_tmp')) %}

with base as (

    select * 
    from {{ ref('stg_shopify__collection_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=source_columns_in_relation,
                staging_columns=get_collection_columns()
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
        id as collection_id,
        _fivetran_deleted as is_deleted,
        case 
            when disjunctive is null then null
            when disjunctive then 'disjunctive'
            else 'conjunctive' end as rule_logic,
        handle,
        published_scope,
        {{ shopify.json_to_string("rules", source_columns_in_relation) }} as rules,
        sort_order,
        title,
        {{ shopify.fivetran_convert_timezone(column='cast(published_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as published_at,
        {{ shopify.fivetran_convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ shopify.fivetran_convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields
)

select *
from final
