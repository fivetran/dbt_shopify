with source as (

    select * from {{ source('salla_raw', 'product_quantities') }}

),

renamed as (

    select
        -- ids
        id as product_quantity_id,
        product_id,
        variant_id,
        branch_id,

        -- quantities
        available_quantity,
        committed_quantity,
        incoming_quantity,

        -- dates
        last_updated as last_updated_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
