with discount_code as (

    select *
    from {{ var('shopify__discount_code') }}
),

discount_allocation as (

    select *
    from {{ var('shopify_discount_allocation') }}
),

discount_application as (

    select *
    from {{ var('shopify_discount_application') }}
),

{% if var('shopify_using_discount_basic_code', true) %}
discount_basic_code as (

    select *
    from {{ var('shopify__discount_basic_code') }}
)
{% endif %}

, discount_code_enhanced as (

    select
        discount_code.discount_code_id,
        discount_code.source_relation,
        discount_code.code,
        discount_code.price_rule_id,
        discount_code.usage_count,
        discount_code.created_at,
        discount_code.updated_at,

        {% if var('shopify_using_discount_basic_code', true) %}
        discount_basic_code.applies_once_per_customer,
        discount_basic_code.starts_at,
        discount_basic_code.ends_at
        {% else %}
        cast(null as boolean) as applies_once_per_customer,
        cast(null as {{ dbt.type_timestamp() }}) as starts_at,
        cast(null as {{ dbt.type_timestamp() }}) as ends_at
        {% endif %}

    from discount_code
    {% if var('shopify_using_discount_basic_code', true) %}
    left join discount_basic_code
        on discount_code.discount_code_id = discount_basic_code.discount_code_id
        and discount_code.source_relation = discount_basic_code.source_relation
    {% endif %}
),

discounts_with_application as (

    select
        discount_code_enhanced.discount_code_id,
        discount_code_enhanced.code,
        discount_code_enhanced.price_rule_id,
        discount_code_enhanced.usage_count,
        discount_code_enhanced.created_at,
        discount_code_enhanced.updated_at,
        discount_code_enhanced.source_relation,
        discount_code_enhanced.applies_once_per_customer,
        discount_code_enhanced.starts_at,
        discount_code_enhanced.ends_at,

        discount_application.allocation_method,
        discount_application.description,
        discount_application.target_selection,
        discount_application.target_type,
        discount_application.title,
        discount_application.type,
        discount_application.value,
        discount_application.value_type

    from discount_code_enhanced
    left join discount_application
        on discount_code_enriched.code = discount_application.code
        and discount_code_enriched.source_relation = discount_application.source_relation
),

discounts_final as (

    select
        discounts_with_application.discount_code_id,
        discounts_with_application.code,
        discounts_with_application.price_rule_id,
        discounts_with_application.usage_count,
        discounts_with_application.created_at,
        discounts_with_application.updated_at,
        discounts_with_application._fivetran_synced,
        discounts_with_application.source_relation,
        discounts_with_application.applies_once_per_customer,
        discounts_with_application.starts_at,
        discounts_with_application.ends_at,

        discounts_with_application.allocation_method,
        discounts_with_application.description,
        discounts_with_application.target_selection,
        discounts_with_application.target_type,
        discounts_with_application.title,
        discounts_with_application.type,
        discounts_with_application.value,
        discounts_with_application.value_type,

        discount_allocation.amount,
        discount_allocation.amount_set_presentment_money_amount,
        discount_allocation.amount_set_presentment_money_currency_code,
        discount_allocation.amount_set_shop_money_amount,
        discount_allocation.amount_set_shop_money_currency_code,
        discount_allocation.order_line_id

    from discounts_with_application
    left join discount_allocation
        on discounts_with_application.discount_code_id = discount_allocation.discount_application_index
        and discounts_with_application.source_relation = discount_allocation.source_relation
)

select *
from discounts_final
