with order_line as (

    select
        *,
        row_number() over (partition by order_id order by order_line_id) as index
    from {{ ref('stg_shopify__order_line') }}

), product_variants as (

    select * from {{ source('shopify_raw', 'product_variants') }}

), refunds as (

    select * from {{ ref('stg_shopify__refund') }}

), refund_line_items_unnested as (

    select
        refund_id,
        order_id,
        source_relation,
        refund_line_item

    from refunds,
    unnest(json_extract_array(refund_line_items)) as refund_line_item
    where refund_line_items is not null

), refund_line_items_parsed as (

    select
        cast(json_extract_scalar(refund_line_item, '$.line_item_id') as int64) as order_line_id,
        order_id,
        source_relation,
        cast(json_extract_scalar(refund_line_item, '$.quantity') as int64) as refunded_quantity,
        cast(json_extract_scalar(refund_line_item, '$.subtotal') as numeric) as refunded_subtotal,
        json_extract_scalar(refund_line_item, '$.restock_type') as restock_type

    from refund_line_items_unnested

), refund_aggregates as (

    select
        order_line_id,
        source_relation,
        string_agg(distinct restock_type, ', ') as restock_types,
        sum(refunded_quantity) as refunded_quantity,
        sum(refunded_subtotal) as refunded_subtotal

    from refund_line_items_parsed
    group by 1, 2

), tax_lines as (

    select
        order_line_id,
        source_relation,
        sum(price) as order_line_tax

    from {{ ref('stg_shopify__tax_line') }}
    where order_line_id is not null
    group by 1, 2

), joined as (

    select
        order_line.*,
        {{ dbt_utils.generate_surrogate_key(['order_line.source_relation', 'order_line.order_line_id']) }} as order_lines_unique_key,

        -- refund info
        refund_aggregates.restock_types,
        coalesce(refund_aggregates.refunded_quantity, 0) as refunded_quantity,
        coalesce(refund_aggregates.refunded_subtotal, 0) as refunded_subtotal,
        order_line.quantity - coalesce(refund_aggregates.refunded_quantity, 0) as quantity_net_refunds,
        (order_line.price * order_line.quantity) - coalesce(refund_aggregates.refunded_subtotal, 0) as subtotal_net_refunds,

        -- variant info
        product_variants.created_at as variant_created_at,
        product_variants.updated_at as variant_updated_at,
        product_variants.inventory_item_id,
        product_variants.image_id as media_id,
        cast(product_variants.price as numeric) as variant_price,
        product_variants.sku as variant_sku,
        product_variants.position as variant_position,
        product_variants.inventory_policy as variant_inventory_policy,
        product_variants.compare_at_price as variant_compare_at_price,
        cast(null as string) as variant_fulfillment_service, -- not available in Airbyte schema
        product_variants.taxable as variant_is_taxable,
        product_variants.barcode as variant_barcode,
        product_variants.grams as variant_grams,
        product_variants.inventory_quantity as variant_inventory_quantity,
        product_variants.weight as variant_weight,
        product_variants.weight_unit as variant_weight_unit,
        product_variants.option1 as variant_option_1,
        product_variants.option2 as variant_option_2,
        product_variants.option3 as variant_option_3,
        product_variants.tax_code as variant_tax_code,
        product_variants.available_for_sale as variant_is_available_for_sale,
        product_variants.display_name as variant_display_name,
        cast(null as int64) as variant_legacy_resource_id, -- not available in new schema
        cast(null as bool) as variant_has_components_required, -- not available in new schema
        cast(null as int64) as variant_sellable_online_quantity, -- not available in new schema

        -- tax
        coalesce(tax_lines.order_line_tax, 0) as order_line_tax

    from order_line
    left join refund_aggregates
        on order_line.order_line_id = refund_aggregates.order_line_id
        and order_line.source_relation = refund_aggregates.source_relation
    left join product_variants
        on order_line.variant_id = product_variants.id
    left join tax_lines
        on order_line.order_line_id = tax_lines.order_line_id
        and order_line.source_relation = tax_lines.source_relation

)

select * from joined
