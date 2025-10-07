with source as (

    select * from {{ source('shopify_raw', 'orders') }}

),

renamed as (

    select
        -- ids
        id as order_id,
        user_id,
        cast(json_extract_scalar(customer, '$.id') as int64) as customer_id,  -- Extract customer id from JSON object
        location_id,

        -- order identifiers
        name,
        number,
        order_number,
        token,
        checkout_id,
        checkout_token,
        cart_token,

        -- dates
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        processed_at as processed_timestamp,
        cancelled_at as cancelled_timestamp,
        closed_at as closed_timestamp,

        -- amounts
        total_price,
        subtotal_price,
        total_discounts,
        total_line_items_price,
        total_tax,
        total_weight,
        total_tip_received,

        -- JSON string fields (keep as is, will parse in intermediate models)
        total_discounts_set,
        total_line_items_price_set,
        total_price_set,
        total_tax_set,
        total_shipping_price_set,
        subtotal_price_set,

        -- status fields
        financial_status,
        fulfillment_status,
        cancel_reason,
        source_name,

        -- contact info
        email,
        phone,
        contact_email,

        -- addresses (keep as JSON for now)
        billing_address,
        shipping_address,

        -- customer details
        browser_ip,
        customer_locale,

        -- flags
        test,
        confirmed,
        taxes_included as has_taxes_included,
        buyer_accepts_marketing as has_buyer_accepted_marketing,

        -- urls and references
        landing_site,
        referring_site,
        source_url,
        order_status_url,

        -- notes
        note,

        -- currency
        currency,
        presentment_currency,

        -- metadata
        note_attributes, -- JSON
        tags,

        -- complex nested fields (JSON arrays - will unnest in separate models)
        line_items, -- will become stg_shopify__order_line
        shipping_lines, -- will become stg_shopify__order_shipping_line
        tax_lines, -- will become stg_shopify__tax_line
        discount_codes, -- will become stg_shopify__order_discount_code
        refunds, -- will become stg_shopify__refund

        -- deleted flag (if exists)
        deleted_at,
        deleted_message,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation,

        -- app_id
        app_id,

        -- company
        company

    from source

)

select * from renamed
