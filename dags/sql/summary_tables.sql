insert into Daily_Customers_Transactions (DW_customer_ID,date,country,media_source,installation_date,last_seen,last_order,
                                         days_since_installation,days_since_last_seen,days_since_last_order,engagement_status)


with dates as (
select 
DW_customer_ID,
date,
country,
media_source, 
installation_date,
valid_until,
(select max(date(event_time)) from DWH_Fact_Events e where e.DW_customer_ID = c.DW_customer_ID and date(event_time) <=date) last_Seen,
(select max(date(order_time)) from dwh_fact_product_in_order o where o.DW_customer_ID = c.DW_customer_ID and date(order_time) <=date) last_order
from dwh_dim_customers c join dwh_dim_dates d on c.installation_date <=d.date
where c.valid_until is null and  (c.DW_customer_ID, date) not in 
                                                            ( --Incremental loading
                                                            select distinct DW_customer_ID, date
                                                            from Daily_Customers_Transactions
                                                            ) 
),

temp as (
    select 
    DW_customer_ID,
    date,
    country,
    media_source, 
    installation_date,
    last_Seen,
    last_order,
    (date - installation_date) as days_since_installation,
    (date - last_seen) as days_since_last_seen,
    (date - last_order) as days_since_last_order
    from dates
    )
    select 
    DW_customer_ID, 
    date, 
    country, 
    media_source, 
    installation_date, 
    last_seen,
    last_order,
    days_since_installation,
    days_since_last_seen,
    days_since_last_order,
    case when installation_date >= (date - 7) then 'New'  --customer who installed the app in the past 7 days.  
    when last_seen < (date - 14) then 'Non-Engaged'
    when last_order is null or last_order < (date - 14) then 'Mid-Engaged'
    when last_order >= (date - 14) then 'Engaged'
    end 
    from temp ;


insert into Daily_Purchase_Agg (DW_customer_ID,order_date,country,supplier,category,media_source,total_cost,total_quantity,total_purchase_USD)
select 
DW_Customer_ID,
date(order_time),
country,
supplier,
category, 
media_source, 
sum(total_cost),
sum(quantity),
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


--Monthly_Product_Rank
insert into Monthly_Product_Rank (DW_product_ID,first_day_of_month,category,number_of_orders,total_quantity,net_profit,
                                  orders_percent_rank,quantity_percent_rank,profit_percent_rank)
with cte as (
select 
dw_product_id, 
(DATE_TRUNC('MONTH', order_time))::DATE as first_day_of_month,
category,
count(order_id) number_of_orders,
sum(quantity) total_quantity,
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
number_of_orders,
total_quantity,
net_profit,
percent_rank() over (partition by category, first_day_of_month order by number_of_orders),
percent_rank() over (partition by category, first_day_of_month order by total_quantity),
percent_rank() over (partition by category, first_day_of_month order by net_profit)
from cte;                              

--Monthly_Supplier_Rank
insert into Monthly_Supplier_Rank (category,first_day_of_month,supplier,number_of_orders,total_quantity,net_profit,
                                   orders_percent_rank,quantity_percent_rank, profit_percent_rank)
with cte as (
select 
category,
(DATE_TRUNC('MONTH', order_time))::DATE as first_day_of_month,
supplier,
count(order_id) number_of_orders,
sum(quantity) total_quantity,
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
number_of_orders,
total_quantity,
net_profit,
percent_rank() over (partition by category, first_day_of_month order by number_of_orders),
percent_rank() over (partition by category, first_day_of_month order by total_quantity),
percent_rank() over (partition by category, first_day_of_month order by net_profit)
from cte;  