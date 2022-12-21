with customers as (

    select 
        *,
        row_number() over(partition by email order by created_at desc) as customer_index

    from {{ var('shopify_customer') }}
    where email is not null -- nonsensical to include any null emails here

), rollup_customers as (

    select
        -- fields to group by
        lower(email) as email,
        source_relation,

        -- fields to string agg together
        {{ fivetran_utils.string_agg("cast(customer_id as " ~ dbt.type_string() ~ ")", "', '") }} as customer_ids,
        {{ fivetran_utils.string_agg("distinct cast(phone as " ~ dbt.type_string() ~ ")", "', '") }} as phone_numbers,

        -- fields to take aggregates of
        min(created_at) as first_account_created_at,
        max(created_at) as last_account_created_at,
        max(updated_at) as last_updated_at,
        max(accepts_marketing_updated_at) as accepts_marketing_last_updated_at,
        max(_fivetran_synced) as last_fivetran_synced,
        sum(orders_count) as orders_count,
        sum(total_spent) as total_spent,

        -- take true if ever given for boolean fields
        {{ fivetran_utils.max_bool("has_accepted_marketing") }} as has_accepted_marketing,
        {{ fivetran_utils.max_bool("case when customer_index = 1 then is_tax_exempt else null end") }} as is_tax_exempt, -- since this changes every year
        {{ fivetran_utils.max_bool("is_verified_email") }} as is_verified_email,

        -- for all other fields, just take the latest value
        {% set cols = adapter.get_columns_in_relation(ref('stg_shopify__customer')) %}
        {% set except_cols = ['_fivetran_synced', 'email', 'source_relation', 'customer_id', 'phone', 'created_at', 
                                'updated_at', 'has_accepted_marketing', 'accepts_marketing_updated_at', 'orders_count', 'total_spent',
                                'is_tax_exempt', 'is_verified_email'] %}
        {% for col in cols %}
            {% if col.column|lower not in except_cols %}
            , max(case when customer_index = 1 then {{ col.column }} else null end) as {{ col.column }}
            {% endif %}
        {% endfor %}

    from customers 

    group by 1,2

)

select *
from rollup_customers