truncate table DWH_Dim_Products_Backup;
truncate table DWH_Dim_Customers_Backup;
truncate table DWH_Fact_Product_In_Order_Backup;
truncate table DWH_Fact_Events_backup;
truncate table Daily_Customers_Transactions_backup;
truncate table Daily_Purchase_Agg_backup;
truncate table Daily_Event_Agg_backup;
truncate table Monthly_Product_Rank_backup;
truncate table Monthly_Supplier_Rank_backup;




insert into DWH_Dim_Products_Backup(DW_product_ID,Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost,Valid_From,Valid_Until)
select * from DWH_Dim_Products;

insert into DWH_Dim_Customers_Backup(DW_Customer_ID,Customer_ID,country,currency,exchange_to_USD,installation_date,media_source,Valid_From,Valid_Until)
select * from DWH_Dim_Customers;

insert into DWH_Fact_Product_In_Order_Backup(Order_ID,DW_product_ID,DW_Customer_ID,Order_Time,country, currency, exchange_to_USD,installation_date,media_source, supplier,
                                             category,Quantity,total_price_before_discount,Total_Cost, total_price_after_discount)
select * from DWH_Fact_Product_In_Order;

insert into DWH_Fact_Events_backup(event_ID,event_description,event_time,DW_customer_ID,country,currency,exchange_to_USD,installation_date,media_source)
select * from DWH_Fact_Events;

insert into Daily_Customers_Transactions_backup(DW_customer_ID,date,country,media_source,installation_date,last_seen, days_since_installation,days_since_last_seen,engagement_status)
select * from Daily_Customers_Transactions;

insert into Daily_Purchase_Agg_backup(DW_customer_ID,order_date,country,supplier,category,media_source,total_cost,total_purchase_USD)
select * from Daily_Purchase_Agg;

insert into Daily_Event_Agg_backup(event_description,event_date,country,media_source,count)
select * from Daily_Event_Agg;

insert into Monthly_Product_Rank_backup(DW_product_ID,first_day_of_month,category,popularity_percent_rank,profitabilty_percent_rank)
select * from monthly_Product_Rank;

insert into Monthly_Supplier_Rank_backup(category,first_day_of_month,supplier, popularity_percent_rank, profitabilty_percent_rank)
select * from monthly_Supplier_Rank;