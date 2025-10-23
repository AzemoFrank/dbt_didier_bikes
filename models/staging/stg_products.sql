{{ config(
    unique_key='product_id',
    partition_by={"field": "insert_date", "data_type": "timestamp"},
    cluster_by=["brand_id", "category_id"]
) }}

with source_data as (
    select
        cast(product_id as string) as product_id,
        cast(product_name as string) as product_name,
        cast(brand_id as string) as brand_id,
        cast(category_id as string) as category_id,
        cast(model_year as string) as model_year,
        cast(list_price as float64) as unit_price,
        current_timestamp() as insert_date,
        current_timestamp() as update_date
    from {{ source('didier_bikes_raw', 'raw_products') }}
)

select * from source_data

{% if is_incremental() %}
  where product_id not in (select distinct product_id from {{ this }})
  or insert_date > (select ifnull(max(insert_date), '1900-01-01') from {{ this }})
{% endif %}
