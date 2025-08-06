{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with customer as (

    select *
    from {{ var('shopify_gql_customer') }}
),

customer_address as (

    select *
    from {{ var('shopify_gql_customer_address') }}
),

customer_default_address as (

    select *
    from customer_address
    where coalesce(is_default, false)
),

joined as (

    select 
        customer.*,
        customer_default_address.customer_address_id as default_address_id
        {# QUESTION: maybe add other fields that are helpful (would be new)? #}
    
    from customer 
    left join customer_default_address
        on customer_default_address.customer_id = customer.customer_id
        and customer_default_address.source_relation = customer.source_relation
)

select *
from joined