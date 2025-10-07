with inventory_level as (

    select * from {{ ref('stg_shopify__inventory_level') }}

), inventory_item as (

    select * from {{ ref('stg_shopify__inventory_item') }}

), location as (

    select * from {{ ref('stg_shopify__location') }}

), product_variant as (

    select * from {{ ref('stg_shopify__product_variant') }}

), product as (

    select * from {{ ref('stg_shopify__product') }}

), inventory_level_aggregated as (

    select * from {{ ref('int_shopify__inventory_level__aggregates') }}

), joined as (

    select
        inventory_level.inventory_level_id,
        inventory_level.inventory_item_id,
        inventory_level.location_id,
        inventory_level.can_deactivate,
        inventory_level.deactivation_alert,
        inventory_level.created_at,
        inventory_level.updated_at,
        inventory_level._fivetran_synced,
        inventory_level.source_relation,

        -- inventory item fields
        inventory_item.sku,
        inventory_item.is_inventory_item_deleted,
        inventory_item.unit_cost_amount,
        inventory_item.unit_cost_currency_code,
        inventory_item.country_code_of_origin,
        inventory_item.province_code_of_origin,
        inventory_item.is_shipping_required,
        inventory_item.is_inventory_quantity_tracked,
        inventory_item.inventory_item_created_at,
        inventory_item.inventory_item_updated_at,
        inventory_item.duplicate_sku_count,
        inventory_item.harmonized_system_code,

        -- location fields
        location.location_name,
        location.is_location_deleted,
        location.is_location_active,
        location.address_1,
        location.address_2,
        location.city,
        location.country,
        location.country_code,
        location.is_legacy_location,
        location.province,
        location.province_code,
        location.phone,
        location.zip,
        location.location_created_at,
        location.location_updated_at,

        -- variant fields
        product_variant.variant_id,
        product_variant.product_id,
        product_variant.variant_title,
        product_variant.variant_inventory_policy,
        product_variant.variant_price,
        product_variant.media_id as variant_media_id,
        product_variant.variant_fulfillment_service,
        product_variant.variant_inventory_management,
        product_variant.variant_is_taxable,
        product_variant.variant_barcode,
        product_variant.variant_grams,
        product_variant.variant_inventory_quantity,
        product_variant.variant_weight,
        product_variant.variant_weight_unit,
        product_variant.variant_option_1,
        product_variant.variant_option_2,
        product_variant.variant_option_3,
        product_variant.variant_tax_code,
        product_variant.variant_created_at,
        product_variant.variant_updated_at,
        product_variant.variant_is_available_for_sale,
        product_variant.variant_display_name,

        -- sales aggregates
        coalesce(inventory_level_aggregated.subtotal_sold, 0) as subtotal_sold,
        coalesce(inventory_level_aggregated.quantity_sold, 0) as quantity_sold,
        coalesce(inventory_level_aggregated.count_distinct_orders, 0) as count_distinct_orders,
        coalesce(inventory_level_aggregated.count_distinct_customers, 0) as count_distinct_customers,
        coalesce(inventory_level_aggregated.count_distinct_customer_emails, 0) as count_distinct_customer_emails,
        inventory_level_aggregated.first_order_timestamp,
        inventory_level_aggregated.last_order_timestamp,
        coalesce(inventory_level_aggregated.subtotal_sold_refunds, 0) as subtotal_sold_refunds,
        coalesce(inventory_level_aggregated.quantity_sold_refunds, 0) as quantity_sold_refunds,
        coalesce(inventory_level_aggregated.count_fulfillment_pending, 0) as count_fulfillment_pending,
        coalesce(inventory_level_aggregated.count_fulfillment_open, 0) as count_fulfillment_open,
        coalesce(inventory_level_aggregated.count_fulfillment_success, 0) as count_fulfillment_success,
        coalesce(inventory_level_aggregated.count_fulfillment_cancelled, 0) as count_fulfillment_cancelled,
        coalesce(inventory_level_aggregated.count_fulfillment_error, 0) as count_fulfillment_error,
        coalesce(inventory_level_aggregated.count_fulfillment_failure, 0) as count_fulfillment_failure,

        -- inventory quantities (available from raw data)
        inventory_level.available as on_hand_quantity,
        inventory_level.available as available_quantity,

        -- net metrics
        coalesce(inventory_level_aggregated.net_subtotal_sold, 0) as net_subtotal_sold,
        coalesce(inventory_level_aggregated.net_quantity_sold, 0) as net_quantity_sold

    from inventory_level
    left join inventory_item
        on inventory_level.inventory_item_id = inventory_item.inventory_item_id
        and inventory_level.source_relation = inventory_item.source_relation
    left join location
        on inventory_level.location_id = location.location_id
        and inventory_level.source_relation = location.source_relation
    left join product_variant
        on inventory_item.inventory_item_id = product_variant.inventory_item_id
        and inventory_level.source_relation = product_variant.source_relation
    left join product
        on product_variant.product_id = product.product_id
        and inventory_level.source_relation = product.source_relation
    left join inventory_level_aggregated
        on product_variant.variant_id = inventory_level_aggregated.variant_id
        and inventory_level.source_relation = inventory_level_aggregated.source_relation

)

select * from joined
