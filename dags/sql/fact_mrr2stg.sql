
insert into STG_Fact_Orders (Order_ID,Order_Time,Customer_ID,Employee_ID,Shipper_ID)
select 
cast(Order_ID as integer),
case
    -- YYYY-MM-DD HH24:MI:SS
    when Order_Time ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'YYYY-MM-DD HH24:MI:SS')
    -- DD-MM-YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'DD-MM-YYYY HH24:MI:SS')
    -- MM-DD-YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'MM-DD-YYYY HH24:MI:SS')
    -- YYYY/MM/DD HH24:MI:SS
    when Order_Time ~ '^\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'YYYY/MM/DD HH24:MI:SS')
    -- DD/MM/YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'DD/MM/YYYY HH24:MI:SS')
    -- MM/DD/YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'MM/DD/YYYY HH24:MI:SS')
    -- YYYY.MM.DD HH24:MI:SS
    when Order_Time ~ '^\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'YYYY.MM.DD HH24:MI:SS')
    -- DD.MM.YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'DD.MM.YYYY HH24:MI:SS')
    -- MM.DD.YYYY HH24:MI:SS
    when Order_Time ~ '^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(Order_Time, 'MM.DD.YYYY HH24:MI:SS')
    else '1900-01-01 00:00:00' end,
case when Customer_ID similar to '[0-9]+' then cast(Customer_ID as int) else 0 end,
case when Employee_ID similar to '[0-9]+' then cast(Employee_ID as int) else 0 end,
case when Shipper_ID similar to '[0-9]+' then cast(Shipper_ID as int) else 0 end
from MRR_Fact_Orders;


insert into STG_Fact_Details (Order_ID,Product_ID,Quantity)
select 
cast(Order_ID as integer),
cast(Product_ID as integer),
case when Quantity similar to '[0-9]+' and cast(Quantity as int) >0 then cast(Quantity as int) else null end
from MRR_Fact_Details;