{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with product_variants as (

    select *
    from {{ ref('stg_shopify_gql__product_variant') }}
),

inventory_item as (

    select *
    from {{ ref('stg_shopify_gql__inventory_item') }}
),

joined as (

    select
        product_variants.*,
        inventory_item.measurement_weight_value as weight,
        inventory_item.measurement_weight_unit as weight_unit

    from product_variants
    left join inventory_item
        on product_variants.inventory_item_id = inventory_item.inventory_item_id
)

select *
from joined