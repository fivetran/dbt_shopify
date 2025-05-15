{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with discount_redeem_code as (

    select 
        code,
        discount_code_id,
        source_relation
    from {{ ref('stg_shopify__discount_redeem_code') }} 
    group by 1, 2, 3
),

discount_codes_unioned as (

    select
        discount_code_id,
        source_relation 
    from {{ ref('stg_shopify__discount_code_basic') }} 
    group by 1, 2

    union all

    select
        discount_code_id,
        source_relation 
    from {{ ref('stg_shopify__discount_code_bxgy') }} 
    group by 1, 2

    union all

    select
        discount_code_id,
        source_relation 
    from {{ ref('stg_shopify__discount_code_free_shipping') }} 
    group by 1, 2

    {% if var('shopify_using_discount_code_app', False) %}

    union all

    select
        discount_code_id,
        source_relation 
    from {{ ref('stg_shopify__discount_code_app') }} 
    group by 1, 2

    {% endif %}
),

discount_codes_source as (
    
    select 
        discount_redeem_code.code, 
        discount_redeem_code.source_relation,
        count(*) as code_count_source
    from discount_redeem_code
    left join discount_codes_unioned
        on discount_redeem_code.discount_code_id = discount_codes_unioned.discount_code_id
        and discount_redeem_code.source_relation = discount_codes_unioned.source_relation
    group by 1, 2
),


discount_codes_end as (

    select 
        code, 
        source_relation,
        count(*) as code_count_end
    from {{ ref('shopify__discounts') }}
    group by 1, 2
),


final as (

    select 
        discount_codes_source.code,
        discount_codes_source.source_relation,
        discount_codes_source.code_count_source,
        discount_codes_end.code_count_end
    from discount_codes_source
    full outer join discount_codes_end
        on discount_codes_source.code = discount_codes_end.code
        and discount_codes_source.source_relation = discount_codes_end.source_relation
)

select *
from final
where code_count_source != code_count_end