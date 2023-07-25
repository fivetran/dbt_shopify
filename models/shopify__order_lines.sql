with order_lines as (

    select *
    from {{ var('shopify_order_line') }}

), product_variants as (

    select *
    from {{ var('shopify_product_variant') }}

), refunds as (

    select *
    from {{ ref('shopify__orders__order_refunds') }}

), refunds_aggregated as (
    
    select
        order_line_id,
        source_relation,
        sum(quantity) as quantity,
        sum(coalesce(subtotal, 0)) as subtotal,
        {{ fivetran_utils.string_agg("distinct cast(refunds.restock_type as " ~ dbt.type_string() ~ ")", "', '") }} as restock_types
    from refunds
    group by 1,2

), tax_lines as (

    select *
    from {{ var('shopify_tax_line')}}

), tax_lines_aggregated as (

    select
        tax_lines.order_line_id,
        tax_lines.source_relation,
        sum(tax_lines.price) as order_line_tax

    from tax_lines
    group by 1,2

), discount_allocation as (

    select *
    from {{ var('shopify_discount_allocation') }}

),
joined as (

    select
        order_lines.*,
        
        refunds_aggregated.restock_types,

        coalesce(refunds_aggregated.quantity,0) as refunded_quantity,
        coalesce(refunds_aggregated.subtotal,0) as refunded_subtotal,
        order_lines.quantity - coalesce(refunds_aggregated.quantity,0) as quantity_net_refunds,
        order_lines.pre_tax_price  - coalesce(refunds_aggregated.subtotal,0) as subtotal_net_refunds,
        
        product_variants.created_timestamp as variant_created_at,
        product_variants.updated_timestamp as variant_updated_at,
        product_variants.inventory_item_id,
        product_variants.image_id,

        product_variants.price as variant_price,
        product_variants.sku as variant_sku,
        product_variants.position as variant_position,
        product_variants.inventory_policy as variant_inventory_policy,
        product_variants.compare_at_price as variant_compare_at_price,
        product_variants.fulfillment_service as variant_fulfillment_service,

        product_variants.is_taxable as variant_is_taxable,
        product_variants.barcode as variant_barcode,
        product_variants.grams as variant_grams,
        product_variants.inventory_quantity as variant_inventory_quantity,
        product_variants.weight as variant_weight,
        product_variants.weight_unit as variant_weight_unit,
        product_variants.option_1 as variant_option_1,
        product_variants.option_2 as variant_option_2,
        product_variants.option_3 as variant_option_3,
        product_variants.tax_code as variant_tax_code,

        tax_lines_aggregated.order_line_tax,
        discount_allocation.amount AS order_line_discount_allocation

    from order_lines
    left join refunds_aggregated
        on refunds_aggregated.order_line_id = order_lines.order_line_id
        and refunds_aggregated.source_relation = order_lines.source_relation
    left join product_variants
        on product_variants.variant_id = order_lines.variant_id
        and product_variants.source_relation = order_lines.source_relation
    left join tax_lines_aggregated
        on tax_lines_aggregated.order_line_id = order_lines.order_line_id
        and tax_lines_aggregated.source_relation = order_lines.source_relation
    left join discount_allocation
        ON discount_allocation.order_line_id = order_lines.order_line_id
        AND discount_allocation.source_relation = order_lines.source_relation
)

select *
from joined