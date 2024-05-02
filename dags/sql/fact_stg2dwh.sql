insert into DWH_Fact_Product_In_Order (Order_ID,DW_product_ID,DW_Customer_ID,Order_Time,country,currency,exchange_to_usd,installation_date,media_source,
                                      supplier,category,Quantity,total_price_before_discount,Total_Cost, total_price_after_discount)
with cte as (
  select 
  o.order_ID,
  sum(p.unit_price) total_price_before_discount,
  (sum(p.unit_price) * (1-o.coupon_discount)) total_price_after_discount
  from STG_Fact_Orders o join STG_Fact_Details d on o.Order_ID=d.Order_ID 
  left join DWH_Dim_Products p on d.Product_ID=p.Product_ID
  group by o.order_ID, o.coupon_discount
)
select 
o.Order_ID,
p.DW_product_ID,
c.DW_Customer_ID,
o.Order_Time,
c.country,
c.currency,
c.exchange_to_usd,
c.installation_date,
c.media_source,
p.supplier,
p.category,
d.Quantity,
(d.Quantity * p.Unit_Price) as Total_Price,
(d.Quantity * p.Unit_Cost) as Total_Cost,
cte.total_price_after_discount * ((d.Quantity * p.Unit_Price)/cte.total_price_before_discount)
from STG_Fact_Orders o join STG_Fact_Details d on o.Order_ID=d.Order_ID 
join cte on cte.order_ID = o.order_ID
left join DWH_Dim_Customers c on o.Customer_ID=c.Customer_ID --left join in case there is a customer who isn't shown in DWH_Dim_Customers, but he did purchase
left join DWH_Dim_Products p on d.Product_ID=p.Product_ID --left join in case there is a product that isn't shown in DWH_Dim_products, but was purchased
where p.Valid_Until is null and c.Valid_Until is null 
and (o.Order_ID,p.dw_product_id) not in ( select distinct Order_ID, dw_product_id
                                          from DWH_Fact_Product_In_Order
                                        );

insert into DWH_Fact_Events (event_ID,event_description,event_time,DW_customer_ID,country,currency,exchange_to_USD,installation_date,media_source)
select 
event_ID,
event_description,
event_time,
c.DW_customer_ID,
c.country,
c.currency,
c.exchange_to_usd,
c.installation_date,
c.media_source
from STG_Fact_Events e left join DWH_Dim_Customers c on e.customer_ID=c.customer_ID --left join in case there is a customer who isn't shown in DWH_Dim_Customers, but he did purchase
where c.valid_until is null and event_ID not in (select distinct event_ID 
                                                 from DWH_Fact_Events  
                                                 );                       


