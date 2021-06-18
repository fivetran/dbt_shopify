with orders as (

    select *
    from {{ ref('shopify__orders') }}

), fields as (

    select
        {{ dbt_utils.surrogate_key(['order_id',"'order_cancelled'"]) }} as event_id,
        cancelled_timestamp as event_timestamp,
        customer_email,
        'order_cancelled' as event_type,
        total_price * -1.0 as revenue_impact,
        cancel_reason as feature_1,
        customer_order_seq_number as feature_2,
        cast(new_vs_repeat as {{ dbt_utils.type_string() }}) as feature_3,
        'shopify' as source,
        customer_id as source_id,
        cast(null as {{ dbt_utils.type_string() }}) as link
    from orders
    where cancelled_timestamp is not null

)

select *
from fields