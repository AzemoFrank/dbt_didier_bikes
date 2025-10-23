{{ config(
    unique_key='customer_id',
    partition_by={"field": "last_order_date", "data_type": "date"},
    cluster_by=["city", "state"]
) }}

with orders as (
    select customer_id, order_id, order_date
    from {{ ref('stg_orders') }}
),
order_items as (
    select order_id, quantity, unit_price, discount
    from {{ ref('stg_order_items') }}
),
agg as (
    select
        o.customer_id,
        count(distinct o.order_id) as nb_orders,
        sum(oi.quantity * oi.unit_price * (1 - oi.discount)) as total_spent,
        avg(oi.quantity * oi.unit_price * (1 - oi.discount)) as avg_order_value,
        min(o.order_date) as first_order_date,
        max(o.order_date) as last_order_date,
        date_diff(current_timestamp(), max(timestamp(o.order_date)), day) as days_since_last_order
    from orders o
    join order_items oi on o.order_id = oi.order_id
    group by o.customer_id
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.city,
    c.state,
    c.zip_code,
    a.nb_orders,
    a.total_spent,
    a.avg_order_value,
    a.first_order_date,
    a.last_order_date,
    a.days_since_last_order,
    current_timestamp() as insert_date,
    current_timestamp() as update_date
from {{ ref('stg_customers') }} c
left join agg a using(customer_id)

{% if is_incremental() %}
  where last_order_date > (select ifnull(max(last_order_date), '1900-01-01') from {{ this }})
{% endif %}
