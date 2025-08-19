{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with inventory_level as (

    select *
    from {{ var('shopify_gql_inventory_level') }}
), 

inventory_item as (

    select *
    from {{ var('shopify_gql_inventory_item') }}
),

inventory_quantity as (

    select *
    from {{ var('shopify_gql_inventory_quantity') }}
),

location as (

    select *
    from {{ var('shopify_gql_location') }}
),

product_variant as (

    select *
    from {{ var('shopify_gql_product_variant') }}
),

product as (

    select *
    from {{ var('shopify_gql_product') }}
),

inventory_level_aggregated as (

    select *
    from {{ ref('int_shopify_gql__inventory_level_aggregates') }}
),

{% if var('shopify_gql_using_product_variant_media', False) %}
product_variant_media as (

    select *
    from {{ var('shopify_gql_product_variant_media') }}
),
{% endif %}

inventory_quantity_aggregated as (

    select
        inventory_quantity.source_relation,
        inventory_quantity.inventory_item_id,
        inventory_quantity.inventory_level_id

        {% set inventory_states = var('shopify_inventory_states', ['incoming', 'on_hand', 'available', 'committed', 'reserved', 'damaged', 'safety_stock', 'quality_control']) -%}
        {% for inventory_state in inventory_states -%}
            , sum(case when lower(inventory_state_name) = {{ "'" ~ inventory_state|lower ~ "'" }}
                then inventory_quantity.quantity end) as {{ inventory_state }}_quantity
        {% endfor -%}

    from inventory_quantity
    left join inventory_level
        on inventory_quantity.inventory_item_id = inventory_level.inventory_item_id
        and inventory_quantity.inventory_level_id = inventory_level.inventory_level_id
        and inventory_quantity.source_relation = inventory_level.source_relation
    group by 1,2,3
),

joined_info as (

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
        inventory_item.sku,
        inventory_item.is_deleted as is_inventory_item_deleted,
        inventory_item.unit_cost_amount,
        inventory_item.unit_cost_currency_code,
        inventory_item.country_code_of_origin,
        inventory_item.province_code_of_origin,
        inventory_item.is_shipping_required,
        inventory_item.is_inventory_quantity_tracked,
        inventory_item.created_at as inventory_item_created_at,
        inventory_item.updated_at as inventory_item_updated_at,
        inventory_item.duplicate_sku_count,
        inventory_item.harmonized_system_code,
        inventory_item.inventory_history_url,
        inventory_item.legacy_resource_id,
        inventory_item.measurement_id,
        inventory_item.measurement_weight_value,
        inventory_item.measurement_weight_unit,
        inventory_item.is_tracked_editable_locked,
        inventory_item.tracked_editable_reason,
        location.name as location_name, 
        location.is_deleted as is_location_deleted,
        location.is_active as is_location_active,
        location.address_1,
        location.address_2,
        location.city,
        location.country,
        location.country_code,
        location.country_name,
        location.is_legacy as is_legacy_location,
        location.province,
        location.province_code,
        location.phone,
        location.zip,
        location.created_at as location_created_at,
        location.updated_at as location_updated_at,
        product_variant.variant_id,
        product_variant.product_id,
        product_variant.title as variant_title,
        product_variant.inventory_policy as variant_inventory_policy,
        product_variant.price as variant_price,

        {% if var('shopify_gql_using_product_variant_media', False) %}
        product_variant_media.media_id as variant_media_id,
        {% endif %}

        product_variant.is_taxable as is_variant_taxable,
        product_variant.barcode as variant_barcode,
        product_variant.inventory_quantity as variant_inventory_quantity,
        product_variant.tax_code as variant_tax_code,
        product_variant.created_timestamp as variant_created_at,
        product_variant.updated_timestamp as variant_updated_at,
        product_variant.is_available_for_sale as variant_is_available_for_sale,
        product_variant.display_name as variant_display_name,
        product_variant.legacy_resource_id as variant_legacy_resource_id,
        product_variant.has_components_required as variant_has_components_required,
        product_variant.sellable_online_quantity as variant_sellable_online_quantity

        {{ fivetran_utils.persist_pass_through_columns('product_variant_pass_through_columns', identifier='product_variant') }}

    from inventory_level
    join inventory_item 
        on inventory_level.inventory_item_id = inventory_item.inventory_item_id 
        and inventory_level.source_relation = inventory_item.source_relation 
    join location 
        on inventory_level.location_id = location.location_id 
        and inventory_level.source_relation = location.source_relation 
    join product_variant 
        on inventory_item.inventory_item_id = product_variant.inventory_item_id 
        and inventory_item.source_relation = product_variant.source_relation

    {% if var('shopify_gql_using_product_variant_media', False) %}
    left join product_variant_media 
        on product_variant.variant_id = product_variant_media.product_variant_id
        and product_variant.source_relation = product_variant_media.source_relation
    {% endif %}
),

joined_aggregates as (

    select 
        joined_info.*,
        coalesce(inventory_level_aggregated.subtotal_sold, 0) as subtotal_sold,
        coalesce(inventory_level_aggregated.quantity_sold, 0) as quantity_sold,
        coalesce(inventory_level_aggregated.count_distinct_orders, 0) as count_distinct_orders,
        coalesce(inventory_level_aggregated.count_distinct_customers, 0) as count_distinct_customers,
        coalesce(inventory_level_aggregated.count_distinct_customer_emails, 0) as count_distinct_customer_emails,
        inventory_level_aggregated.first_order_timestamp,
        inventory_level_aggregated.last_order_timestamp,
        coalesce(inventory_level_aggregated.subtotal_sold_refunds, 0) as subtotal_sold_refunds,
        coalesce(inventory_level_aggregated.quantity_sold_refunds, 0) as quantity_sold_refunds

        {% for status in ['pending', 'open', 'success', 'cancelled', 'error', 'failure'] %}
        , coalesce(inventory_level_aggregated.count_fulfillment_{{ status }}, 0) as count_fulfillment_{{ status }}
        {% endfor %}

        {% for inventory_state in inventory_states -%}
        , inventory_quantity_aggregated.{{ inventory_state }}_quantity
        {% endfor -%}

    from joined_info
    left join inventory_level_aggregated
        on joined_info.location_id = inventory_level_aggregated.location_id
        and joined_info.variant_id = inventory_level_aggregated.variant_id
        and joined_info.source_relation = inventory_level_aggregated.source_relation
    left join inventory_quantity_aggregated
        on joined_info.inventory_item_id = inventory_quantity_aggregated.inventory_item_id
        and joined_info.inventory_level_id = inventory_quantity_aggregated.inventory_level_id
        and joined_info.source_relation = inventory_quantity_aggregated.source_relation
),

final as (

    select 
        *,
        subtotal_sold - subtotal_sold_refunds as net_subtotal_sold,
        quantity_sold - quantity_sold_refunds as net_quantity_sold
    from joined_aggregates
)

select * 
from final