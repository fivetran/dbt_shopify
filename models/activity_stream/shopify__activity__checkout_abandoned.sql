with checkout as (

    select *
    from {{ var('shopify_abandoned_checkout') }}

), fields as (

    select
        {{ dbt_utils.surrogate_key(['id',"'checkout_abandoned'"]) }} as event_id,
        created_at as event_timestamp,
        email,
        'checkout_abandoned' as event_type,
        null as revenue_impact,
        source_name as feature_1,
        cast(null as {{ dbt_utils.type_string() }}) as feature_2,
        cast(null as {{ dbt_utils.type_string() }}) as feature_3
    from checkout
    where created_at is not null

)

select *
from fields