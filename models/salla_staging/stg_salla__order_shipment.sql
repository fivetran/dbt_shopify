with source as (

    select * from {{ source('salla_raw', 'order_shipments') }}

),

renamed as (

    select
        -- ids
        id as shipment_id,
        order_id,
        courier_id,

        -- shipment info
        tracking_number,
        status as shipment_status,
        cost as shipment_cost,
        weight,

        -- dates
        pickup_date as pickup_timestamp,
        delivery_date as delivery_timestamp,
        created_at as created_timestamp,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
