with order as (

    select * 
    from {{ ref('stg_shopify_gql__order') }}
),

customer_visit as (
    
    select * 
    from {{ ref('stg_shopify_gql__customer_visit') }}
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