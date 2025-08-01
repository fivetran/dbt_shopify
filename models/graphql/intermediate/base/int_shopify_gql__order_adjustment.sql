{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_adjustment as (

    select *
    from {{ var('shopify_gql_order_adjustment') }}
),

refund as (

    select *
    from {{ var('shopify_gql_refund') }}
),

joined as (

    select 
        order_adjustment.*,
        refund.order_id

    from order_adjustment
    left join refund
        on order_adjustment.refund_id = refund.refund_id
        and order_adjustment.source_relation = refund.source_relation
)

select *
from joined