{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order as (

    select * 
    from {{ var('shopify_gql_order') }}
),

customer_visit as (
    
    select * 
    from {{ var('shopify_gql_customer_visit') }}
),

joined as (

    select 
        order.*,
        customer_visit.referring_site
    from order
    left join customer_visit
        on order.order_id = customer_visit.order_id
        and order.source_relation = customer_visit.source_relation
)

select *
from joined