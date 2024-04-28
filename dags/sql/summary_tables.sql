insert into Daily_Customers_Transactions (DW_customer_ID,date,country,media_source,installation_date,last_seen, days_since_installation,days_since_last_seen,engagement_status)

with last_Seen as (
    select DW_customer_ID, max(date(event_time)) last_seen
    from DWH_Fact_Events
    group by DW_customer_ID
),
last_order as (
    select DW_customer_ID, max(date(order_time)) last_order
    from dwh_fact_product_in_order
    group by DW_customer_ID
),
temp as (
    select 
    src.DW_customer_ID, 
    date, 
    country, 
    media_source, 
    installation_date, 
    e.last_seen,
    date_part('day', AGE(CURRENT_DATE, installation_date)) days_since_installation,
    date_part('day', AGE(CURRENT_DATE, e.last_seen)) days_since_last_seen,
    o.last_order
    from (DWH_Dim_Dates cross join DWH_Dim_Customers) src 
    join last_Seen e on src.DW_customer_ID = e.DW_customer_ID
    join last_order o on src.DW_customer_ID = o.DW_customer_ID 
    where src.valid_until is null and  (src.DW_customer_ID,date) not in 
                                                            ( --Incremental loading
                                                            select distinct DW_customer_ID, date
                                                            from Daily_Customers_Transactions
                                                            )

    )
    select 
    DW_customer_ID, 
    date, 
    country, 
    media_source, 
    installation_date, 
    last_seen,
    days_since_installation,
    days_since_last_seen,
    case when installation_date >= (current_date - 7) then 'New customers'  --customer who installed the app in the past 7 days.  
    when last_seen < (current_date - 14) then 'Non-Engaged'
    when last_order is null or last_order < (current_date - 14) then 'Mid-Engaged'
    when last_order >= (current_date - 14) then 'Engaged'
    end 
    from temp ;


insert into Daily_Purchase_Agg (DW_customer_ID,order_date,country,supplier,category,media_source,total_cost,total_purchase_USD)
select 
DW_Customer_ID,
date(order_time),
country,
supplier,
category, 
media_source, 
sum(total_cost), 
sum(total_price_after_discount * exchange_to_USD)
from dwh_fact_product_in_order
where  (DW_customer_ID, date(order_time)) not in 
                                            ( --Incremental loading
                                            select distinct DW_customer_ID, order_date
                                            from Daily_Purchase_Agg
                                            )
group by DW_Customer_ID, date(order_time), country, supplier, category, media_source;



insert into Daily_Event_Agg (event_description,event_date,country,media_source,count)
select 
event_description, 
date(event_time), 
country, 
media_source, 
count(*)
from DWH_Fact_Events
where  (event_description, date(event_time)) not in 
                                                    ( --Incremental loading
                                                    select distinct event_description, event_date
                                                    from Daily_Event_Agg
                                                    )
group by event_description, date(event_time), country, media_source;



insert into Monthly_Product_Rank (DW_product_ID,first_day_of_month,category,popularity_percent_rank,profitabilty_percent_rank)
with cte as (
select 
dw_product_id, 
(DATE_TRUNC('MONTH', order_time))::DATE as first_day_of_month,
category,
count(order_id) number_of_orders,
sum (total_price_after_discount - total_cost) net_profit
from DWH_Fact_Product_In_Order
where (dw_product_id, (DATE_TRUNC('MONTH', order_time))::DATE) not in --Incremental loading
                                                                    (
                                                                     select distinct dw_product_id, first_day_of_month
                                                                     from Monthly_Product_Rank
                                                                    )
group by dw_product_id, (DATE_TRUNC('MONTH', order_time))::DATE, category                              
)
select 
dw_product_id,
first_day_of_month,
category,
percent_rank() over (partition by category order by number_of_orders),
percent_rank() over (partition by category order by net_profit)
from cte;                              


insert into Monthly_Supplier_Rank (category,first_day_of_month,supplier, popularity_percent_rank, profitabilty_percent_rank)
with cte as (
select 
category,
(DATE_TRUNC('MONTH', order_time))::DATE as first_day_of_month,
supplier,
count(order_id) number_of_orders,
sum (total_price_after_discount - total_cost) net_profit
from DWH_Fact_Product_In_Order
where (category, (DATE_TRUNC('MONTH', order_time))::DATE) not in --Incremental loading
                                                                (
                                                                select distinct category, first_day_of_month
                                                                from Monthly_Supplier_Rank
                                                                )
group by category, (DATE_TRUNC('MONTH', order_time))::DATE, supplier                              
)
select 
category,
first_day_of_month,
supplier,
percent_rank() over (partition by supplier order by number_of_orders),
percent_rank() over (partition by supplier order by net_profit)
from cte;  