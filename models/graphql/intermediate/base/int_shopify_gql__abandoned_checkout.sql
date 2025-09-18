{{ config(enabled=(var('shopify_gql_using_abandoned_checkout', True) and var('shopify_api', 'rest') == var('shopify_api_override','graphql'))) }}

with abandoned_checkout as (

    select *
    from {{ ref('stg_shopify_gql__abandoned_checkout') }}
),

customer as (

    select *
    from {{ ref('stg_shopify_gql__customer') }}
),

add_customer_email as (

    select 
        abandoned_checkout.*,
        customer.email
    from abandoned_checkout
    left join customer
        on abandoned_checkout.customer_id = customer.customer_id
        and abandoned_checkout.source_relation = customer.source_relation
)

select *
from add_customer_email