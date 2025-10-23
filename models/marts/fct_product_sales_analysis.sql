{{ config(
    unique_key='product_id',
    partition_by={"field": "insert_date", "data_type": "timestamp"},
    cluster_by=["category_id", "brand_id"]
) }}

with sales as (
    select
        oi.product_id,
        p.product_name,
        p.category_id,
        p.brand_id,
        p.unit_price as catalog_price,
        sum(oi.quantity) as total_qty_sold,
        sum(oi.quantity * oi.unit_price * (1 - oi.discount)) as total_sales,
        avg(oi.unit_price * (1 - oi.discount)) as avg_sold_price
    from {{ ref('stg_order_items') }} oi
    join {{ ref('stg_products') }} p using(product_id)
    group by 1, 2, 3, 4, 5
),
analysis as (
    select
        s.*,
        current_timestamp() as insert_date,
        current_timestamp() as update_date
    from sales s
)

select *
from analysis
{% if is_incremental() %}
  where insert_date > (select ifnull(max(insert_date), '1900-01-01') from {{ this }})
{% endif %}
