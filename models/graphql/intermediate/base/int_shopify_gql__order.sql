{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with orders as (

    select * 
    from {{ ref('stg_shopify_gql__order') }}
)

{% if var('shopify_gql_using_customer_visit', True) %}
, customer_visit as (
    
    select * 
    from {{ ref('stg_shopify_gql__customer_visit') }}
),

joined as (

    select 
        orders.*,
        customer_visit.referring_site,
        customer_visit.landing_page as landing_site_base_url
    from orders
    left join customer_visit
        on orders.order_id = customer_visit.order_id
        and orders.source_relation = customer_visit.source_relation
)

select *
from joined

{% else %}

select 
    orders.*,
    cast(null as {{ dbt.type_string() }}) as referring_site,
    cast(null as {{ dbt.type_string() }}) as landing_site_base_url
from orders

{% endif %}