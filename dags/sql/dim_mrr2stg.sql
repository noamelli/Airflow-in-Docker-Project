truncate table STG_Dim_Customers;
truncate table STG_Dim_Products;
truncate table STG_Dim_Dates;
truncate table STG_Dim_Time;

insert into STG_Dim_Products(Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost,isValid)
select 
cast(Product_ID as integer),
case when Product_Name is null then 'missing' else Product_Name end,
case when Supplier similar to '[0-9]+' then cast(Supplier as integer) else 0 end,
case when Category similar to '[0-9]+' then cast(Category as integer) else 0 end,
case when Unit_Price similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Price as decimal(15,5))>=0
     then cast(Unit_Price as decimal(15,5)) else null end,
case when Unit_Cost similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Cost as decimal(15,5))>=0
     then cast(Unit_Cost as decimal(15,5)) else null end,
isValid
from MRR_Dim_Products
where isValid='valid';

insert into STG_Dim_Customers(Customer_ID,country,currency,exchange_to_USD,installation_date,media_source,isValid)
select
cast(Customer_ID as integer),
case when country is null then 'missing' else country end,
case when currency is null then 'missing' else currency end,
case when exchange_to_USD similar to '[0-9]+(\.[0-9]+)?' and cast(exchange_to_USD as decimal(3,2))>=0
     then cast(exchange_to_USD as decimal(3,2)) else null end,
case
    -- YYYY-MM-DD
    when installation_date ~ '^\d{4}-\d{2}-\d{2}$' then to_date(installation_date, 'YYYY-MM-DD')
    -- DD-MM-YYYY
    when installation_date ~ '^\d{2}-\d{2}-\d{4}$' then to_date(installation_date, 'DD-MM-YYYY')
    -- YYYY.MM.DD
    when installation_date ~ '^\d{4}.\d{2}.\d{2}$' then to_date(installation_date, 'YYYY.MM.DD')
    -- DD.MM.YYYY
    when installation_date ~ '^\d{2}.\d{2}.\d{4}$' then to_date(installation_date, 'DD.MM.YYYY')
    -- DD/MM/YYYY
    when installation_date ~ '^\d{2}/\d{2}/\d{4}$' then to_date(installation_date, 'DD/MM/YYYY')
    -- YYYY/MM/DD
    when installation_date ~ '^\d{4}/\d{2}/\d{2}$' then to_date(installation_date, 'YYYY/MM/DD')
    -- DD\MM\YYYY
    when installation_date ~ '^\d{2}\\d{2}\\d{4}$' then to_date(installation_date, 'DD\MM\YYYY')
    -- YYYY\MM\DD
    when installation_date ~ '^\d{4}\\d{2}\\d{2}$' then to_date(installation_date, 'YYYY\MM\DD')
    else '1900-01-01' end,
    media_source,
    isValid 
from MRR_Dim_Customers
where isValid='valid';


insert into STG_Dim_Dates(Date,Year,Quarter,Month,Day)
select
generate_series::date,
extract(year from generate_series),
extract(quarter from generate_series),
extract(month from generate_series),
extract(day from generate_series)
from generate_series('2024-01-01'::date, CURRENT_DATE::date, '1 day');


insert into STG_Dim_Time(DateTime, Date, Hour)
SELECT
  generate_series::TIMESTAMP,
  DATE_TRUNC('hour', generate_series::TIMESTAMP),
  EXTRACT(HOUR FROM generate_series::TIMESTAMP) AS hour
FROM
  GENERATE_SERIES('2024-01-01'::TIMESTAMP, CURRENT_DATE::TIMESTAMP, '1 hour');

