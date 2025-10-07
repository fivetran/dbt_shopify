with source as (

    select * from {{ source('salla_raw', 'order_histories') }}

),

renamed as (

    select
        -- ids
        id as order_history_id,
        order_id,
        created_by,

        -- status changes
        status_id,
        status_name,
        previous_status_id,
        previous_status_name,

        -- notes
        note,

        -- dates
        created_at as created_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
