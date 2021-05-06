with product_variants as (

    select *
    from {{ var('product_variant') }}

)

select *
from product_variants