truncate table STG_Fact_Orders;
truncate table STG_Fact_Details;
truncate table STG_Fact_Events;

insert into STG_Fact_Orders (Order_ID,Order_Time,Customer_ID,coupon_discount)
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
case when coupon_discount similar to '[0-9]+(\.[0-9]+)?' and cast(coupon_discount as decimal(3,2))>=0
     then cast(coupon_discount as decimal(3,2)) else null end
from MRR_Fact_Orders;



insert into STG_Fact_Details (Order_ID,Product_ID,Quantity)
select 
cast(Order_ID as integer),
cast(Product_ID as integer),
case when Quantity similar to '[0-9]+' and cast(Quantity as int) >= 0 then cast(Quantity as int) else null end
from MRR_Fact_Details;


insert into STG_Fact_Events (event_ID,event_description,event_time,Customer_ID)
select 
cast(event_ID as integer),
event_description,
case
    -- YYYY-MM-DD HH24:MI:SS
    when event_time ~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'YYYY-MM-DD HH24:MI:SS')
    -- DD-MM-YYYY HH24:MI:SS
    when event_time ~ '^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'DD-MM-YYYY HH24:MI:SS')
    -- MM-DD-YYYY HH24:MI:SS
    when event_time ~ '^\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'MM-DD-YYYY HH24:MI:SS')
    -- YYYY/MM/DD HH24:MI:SS
    when event_time ~ '^\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'YYYY/MM/DD HH24:MI:SS')
    -- DD/MM/YYYY HH24:MI:SS
    when event_time ~ '^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'DD/MM/YYYY HH24:MI:SS')
    -- MM/DD/YYYY HH24:MI:SS
    when event_time ~ '^\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'MM/DD/YYYY HH24:MI:SS')
    -- YYYY.MM.DD HH24:MI:SS
    when event_time ~ '^\d{4}\.\d{2}\.\d{2} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'YYYY.MM.DD HH24:MI:SS')
    -- DD.MM.YYYY HH24:MI:SS
    when event_time ~ '^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'DD.MM.YYYY HH24:MI:SS')
    -- MM.DD.YYYY HH24:MI:SS
    when event_time ~ '^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}:\d{2}$' then to_timestamp(event_time, 'MM.DD.YYYY HH24:MI:SS')
    else '1900-01-01 00:00:00' end,
    case when Customer_ID similar to '[0-9]+' then cast(Customer_ID as int) else 0 end
from MRR_Fact_Events;
