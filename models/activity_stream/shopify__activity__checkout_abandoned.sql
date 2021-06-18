with checkout as (

    select *
    from {{ var('shopify_abandoned_checkout') }}

), fields as (

    select
        {{ dbt_utils.surrogate_key(['id',"'checkout_abandoned'"]) }} as event_id,
        {{ dbt_utils.dateadd('second',1,'created_at') }} as event_timestamp,
        email,
        'checkout_abandoned' as event_type,
        cast(null as {{ dbt_utils.type_float() }}) as revenue_impact,
        source_name as feature_1,
        cast(null as {{ dbt_utils.type_string() }}) as feature_2,
        cast(null as {{ dbt_utils.type_string() }}) as feature_3,
        'shopify' as source,
        customer_id as source_id
    from checkout
    where completed_at is null

)

select *
from fields