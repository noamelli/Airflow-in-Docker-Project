insert into DWH_Dim_Dates (Date,Year,Quarter,Month,Day)
select * 
from STG_Dim_Dates 
where date not in (
                    select distinct date 
                    from DWH_Dim_Dates
                  );

insert into DWH_Dim_Time (DateTime,Date,Hour,Minute)
select * 
from STG_Dim_Time
where DateTime not in (
                    select distinct DateTime 
                    from DWH_Dim_Time
                  );;

--customers
--insert all the new customers records 
insert into DWH_Dim_Customers (Customer_ID,country,currency,exchange_to_USD,installation_date,media_source)
select Customer_ID,country,currency,exchange_to_USD,installation_date,media_source
from STG_Dim_Customers  
where Customer_ID not in (
                          select distinct Customer_ID
                          from DWH_Dim_Customers
                          );



--update the valid until date of customers who moved to another country/their currency has changed 

update DWH_Dim_Customers
set Valid_Until=current_date
where DW_Customer_ID in (
                            select DW_Customer_ID 
                            from STG_Dim_Customers s inner join DWH_Dim_Customers d on d.Customer_ID = s.Customer_ID
                            where (s.currency <> d.currency or s.Country <> d.Country or s.exchange_to_USD <> d.exchange_to_USD) and d.Valid_Until is null
                          );


--insert records of customers who moved to another country/their currency has changed                            
insert into DWH_Dim_Customers (Customer_ID,country,currency,exchange_to_USD,installation_date,media_source)
select s.Customer_ID,s.country,s.currency,s.exchange_to_USD,s.installation_date,s.media_source
from STG_Dim_Customers s inner join DWH_Dim_Customers d on d.Customer_ID=s.Customer_ID
where s.currency <> d.currency or s.Country <> d.Country or s.exchange_to_USD <> d.exchange_to_USD;

--products

-- insert all the new products records 
insert into DWH_Dim_Products (Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost
from STG_Dim_Products s 
where Product_ID not in 
                            (
                              select distinct Product_ID
                              from DWH_Dim_Products       
                            );
-- update the valid until date of products that their price/cost/supplier have changed
update DWH_Dim_Products
set Valid_Until=current_date
where dw_product_id in (
                            select dw_product_id 
                            from STG_Dim_Products s inner join DWH_Dim_Products d on d.Product_ID = s.Product_ID
                            where (s.Unit_Cost <> d.Unit_Cost or s.Unit_Price <> d.Unit_Price or s.Supplier <> d.Supplier) 
                            and d.Valid_Until is null
                          );



-- insert records of products that their price/cost/supplier have changed                             
insert into DWH_Dim_Products (Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select s.Product_ID,s.Product_Name,s.Supplier,s.Category,s.Unit_Price,s.Unit_Cost
from STG_Dim_Products s inner join DWH_Dim_Products d on d.Product_ID=s.Product_ID
where s.Unit_Cost <> d.Unit_Cost or s.Unit_Price <> d.Unit_Price or s.Supplier <> d.Supplier;

