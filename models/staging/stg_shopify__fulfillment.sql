with source as (

    select * from {{ source('shopify_raw', 'fulfillments') }}

),

renamed as (

    select
        -- ids
        id as fulfillment_id,
        order_id,
        location_id,

        -- tracking
        tracking_company,
        tracking_number,
        tracking_numbers, -- JSON array
        tracking_url,
        tracking_urls, -- JSON array

        -- details
        name,
        status,
        shipment_status,
        service,

        -- dates
        created_at as created_timestamp,
        updated_at as updated_timestamp,

        -- flags
        notify_customer,

        -- line items (JSON array)
        line_items,

        -- other
        receipt, -- JSON
        origin_address, -- JSON

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
