with unioned as (

    {{ dbt_utils.union_relations([
        ref('shopify__activity__order_completed'),
        ref('shopify__activity__order_cancelled'),
        ref('shopify__activity__product_purchased'),
        ref('shopify__activity__product_refunded'),
        ref('shopify__activity__checkout_started'),
        ref('shopify__activity__checkout_abandoned')
    ]) }}

)

select *
from unioned