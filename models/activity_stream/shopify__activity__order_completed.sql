with orders as (

    select *
    from {{ ref('shopify__orders') }}

), fields as (

    select
        {{ dbt_utils.surrogate_key(['order_id',"'order_completed'"]) }} as event_id,
        created_timestamp as event_timestamp,
        customer_email,
        'order_completed' as event_type,
        total_price as revenue_impact,
        fulfillment_status as feature_1,
        financial_status as feature_2,
        cast(new_vs_repeat as {{ dbt_utils.type_string() }}) as feature_3,
        'shopify' as source,
        customer_id as source_id
    from orders
    where created_timestamp is not null

)

select *
from fields