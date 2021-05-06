# Shopify

This package models Shopify data from [Fivetran's connector](https://fivetran.com/docs/applications/shopify). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/shopify#schemainformation).

The main focus of the package is to transform the core object tables into analytics-ready models, including a cohort model to understand how your customers are behaving over time.

## Models

This package contains transformation models, designed to work simultaneously with our [Shopify source package](https://github.com/fivetran/dbt_shopify_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below.

| **model**                 | **description**                                                                                                    |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| shopify__customer_cohorts | Each record represents the monthly performance of a customer, including fields for the month of their 'cohort'.    |
| shopify__customers        | Each record represents a customer, with additional dimensions like lifetime value and number of orders.            |
| shopify__orders           | Each record represents an order, with additional dimensions like whether it is a new or repeat purchase.           |
| shopify__order_lines      | Each record represents an order line item, with additional dimensions like how many items were refunded.           |
| shopify__products         | Each record represents a product, with additional dimensions like most recent order date and order volume.         |
| shopify__product_variants | Each record represents a product variant                                                                           |


## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## Configuration
By default, this package looks for your Shopify data in the `shopify` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Shopify data is, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
    shopify_database: your_database_name
    shopify_schema: your_schema_name
```

For additional configurations for the source models, visit the [Shopify source package](https://github.com/fivetran/dbt_shopify_source).

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn more about Fivetran [in the Fivetran docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
