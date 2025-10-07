with source as (

    select * from {{ source('shopify_raw', 'product_variants') }}

),

renamed as (

    select
        -- ids
        id as variant_id,
        product_id,
        inventory_item_id,
        image_id as media_id,

        -- variant info
        title as variant_title,
        sku,
        position as variant_position,
        display_name as variant_display_name,

        -- options
        option1 as variant_option_1,
        option2 as variant_option_2,
        option3 as variant_option_3,

        -- pricing
        cast(price as numeric) as variant_price,
        compare_at_price as variant_compare_at_price,

        -- inventory
        inventory_policy as variant_inventory_policy,
        inventory_quantity as variant_inventory_quantity,
        cast(null as string) as variant_inventory_management, -- stored differently in new schema

        -- fulfillment
        cast(null as string) as variant_fulfillment_service, -- not available

        -- physical properties
        grams as variant_grams,
        weight as variant_weight,
        weight_unit as variant_weight_unit,
        barcode as variant_barcode,

        -- tax
        taxable as variant_is_taxable,
        tax_code as variant_tax_code,

        -- flags
        available_for_sale as variant_is_available_for_sale,
        requires_shipping as is_shipping_required,

        -- dates
        created_at as variant_created_at,
        updated_at as variant_updated_at,

        -- metadata from Airbyte
        _airbyte_extracted_at as _fivetran_synced,

        -- source relation
        'airbyte' as source_relation

    from source

)

select * from renamed
