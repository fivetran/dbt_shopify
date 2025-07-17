{{ config(enabled=var('shopify_api', 'rest') == var('shopify_api_override','graphql')) }}

with order_discount_code as (

    select *
    from {{ var('shopify_gql_order_discount_code') }}
),

discount_application as (

    select *
    from {{ var('shopify_gql_discount_application') }}
),

joined as (

    select 
        order_discount_code.*,
        discount_application.value_type as type,
        discount_application.value_amount,
        discount_application.value_currency_code,
        discount_application.value_percentage,
        discount_application.target_type,
        discount_application.target_selection,
        discount_application.allocation_method

    from order_discount_code
    left join discount_application
        on order_discount_code.order_id = discount_application.order_id
        {# OUTSTANDING: need code, or else some fanout will occur #}
        {# and order_discount_code.index = discount_application.index #}
        and order_discount_code.source_relation = discount_application.source_relation
)

select *
from joined