{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with base as (

    select * 
    from {{ ref('stg_shopify_gql__media_image_tmp') }}
),


fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify_gql__media_image_tmp')),
                staging_columns=get_graphql_media_image_columns()
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
        media_id,
        image_id,
        image_alt_text,
        image_height,
        image_url,
        image_width,
        source_relation,
        {{ dbt_utils.generate_surrogate_key(['media_id', 'image_id', 'source_relation']) }} as unique_key

    from fields
)

select *
from final
