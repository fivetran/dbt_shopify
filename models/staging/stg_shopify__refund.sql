with source as (

    select * from {{ source('shopify_raw', 'order_refunds') }}

),

renamed as (

    select
        -- ids
        id as refund_id,
        order_id,
        user_id,

        -- dates
        created_at as created_timestamp,
        processed_at as processed_timestamp,

        -- notes
        note,

        -- restock flag
        restock,

        -- transactions (JSON array - contains refund transaction details)
        transactions,

        -- refund line items (JSON array - which line items were refunded)
        refund_line_items,

        -- order adjustments (JSON array - shipping refunds, etc)
        order_adjustments,

        -- duties
        duties,
        total_duties_set,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
