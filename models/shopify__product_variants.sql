with product_variants as (

    select *
    from {{ var('shopify_product_variant') }}

)

select *
from product_variants