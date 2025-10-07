with source as (

    select * from {{ source('shopify_raw', 'customers') }}

),

split_tags as (

    select
        id as customer_id,
        tags,
        'airbyte' as source_relation,
        _airbyte_extracted_at as _fivetran_synced

    from source
    where tags is not null
    and trim(tags) != ''

),

unnested as (

    select
        customer_id,
        trim(tag) as value,
        source_relation,
        _fivetran_synced

    from split_tags,
    unnest(split(tags, ',')) as tag

)

select * from unnested
where value is not null
and value != ''
