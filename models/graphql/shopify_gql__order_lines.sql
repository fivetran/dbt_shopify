{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_lines as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation', 'order_line_id']) }} as order_lines_unique_key
    from {{ ref('int_shopify_gql__order_line') }}

), product_variants as (

    select *
    from {{ ref('int_shopify_gql__product_variant') }}

), refunds as (

    select *
    from {{ ref('shopify_gql__orders__order_refunds') }}

), 

{% if var('shopify_gql_using_product_variant_media', False) %}
product_variant_media as (

    select *
    from {{ var('shopify_gql_product_variant_media') }}
),
{% endif %}

refunds_aggregated as (
    
    select
        order_line_id,
        source_relation,
        sum(quantity) as quantity,
        sum(coalesce(subtotal, 0)) as subtotal,
        {{ fivetran_utils.string_agg("distinct cast(refunds.restock_type as " ~ dbt.type_string() ~ ")", "', '") }} as restock_types
    from refunds
    group by 1,2

), joined as (

    select
        order_lines.*,
        refunds_aggregated.restock_types,

        coalesce(refunds_aggregated.quantity,0) as refunded_quantity,
        coalesce(refunds_aggregated.subtotal,0) as refunded_subtotal,
        order_lines.quantity - coalesce(refunds_aggregated.quantity,0) as quantity_net_refunds,
        order_lines.pre_tax_price - coalesce(refunds_aggregated.subtotal,0) as subtotal_net_refunds,
        
        product_variants.created_timestamp as variant_created_at,
        product_variants.updated_timestamp as variant_updated_at,
        product_variants.inventory_item_id,

        {% if var('shopify_gql_using_product_variant_media', False) %}
        product_variant_media.media_id,
        {% endif %}

        product_variants.price as variant_price,
        product_variants.sku as variant_sku,
        product_variants.position as variant_position,
        product_variants.inventory_policy as variant_inventory_policy,
        product_variants.compare_at_price as variant_compare_at_price,
        {# deprecated: product_variants.fulfillment_service as variant_fulfillment_service, #}

        product_variants.is_taxable as variant_is_taxable,
        product_variants.barcode as variant_barcode,
        product_variants.inventory_quantity as variant_inventory_quantity,
        product_variants.weight as variant_weight,
        product_variants.weight_unit as variant_weight_unit,
        {# ALL DEPRECATED:
        product_variants.grams as variant_grams,
        product_variants.option_1 as variant_option_1,
        product_variants.option_2 as variant_option_2,
        product_variants.option_3 as variant_option_3, 
        #}
        -- QUESTION: in REST, we have an order_line.tax_code field that is described identically to product_variants.tax_code, but it is not present in the GraphQL schema.
        -- Should we create a tax_code field that is just a copy of product_variants.tax_code, or should we leave it out?
        product_variants.tax_code as variant_tax_code,
        product_variants.is_available_for_sale as variant_is_available_for_sale,
        product_variants.display_name as variant_display_name,
        product_variants.legacy_resource_id as variant_legacy_resource_id,
        product_variants.has_components_required as variant_has_components_required,
        product_variants.sellable_online_quantity as variant_sellable_online_quantity

    from order_lines
    left join refunds_aggregated
        on refunds_aggregated.order_line_id = order_lines.order_line_id
        and refunds_aggregated.source_relation = order_lines.source_relation
    left join product_variants
        on product_variants.variant_id = order_lines.variant_id
        and product_variants.source_relation = order_lines.source_relation

    {% if var('shopify_gql_using_product_variant_media', False) %}
    left join product_variant_media
        on product_variant_media.product_variant_id = product_variants.variant_id
        and product_variant_media.source_relation = product_variants.source_relation
    {% endif %}
)

select *
from joined