insert into STG_Dim_Products(Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select 
cast(Product_ID as integer),
Product_Name,
case when Supplier similar to '[0-9]+' then cast(Supplier as integer) else 0 end,
case when Category similar to '[0-9]+' then cast(Category as integer) else 0 end,
case when Unit_Price similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Price as decimal(15,5))>=0
    then cast(Unit_Price as decimal(15,5)) else null end,
case when Unit_Cost similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Cost as decimal(15,5))>=0
    then cast(Unit_Cost as decimal(15,5)) else null end
from MRR_Dim_Products;

insert into STG_Dim_Customers(Customer_ID,Company_Name,Contact_Name,Street,City,Postal_Code,Country,Phone,Fax)
select
cast(Customer_ID as integer),
Company_Name,
Contact_Name,
Street,
City,
Postal_Code,
Country,
Phone,
Fax
from MRR_Dim_Customers;

insert into STG_Dim_Employees(Employee_ID,Last_Name,First_Name,Title,Hire_Date,Office,Reports_To,Month_Salary)
select 
cast(Employee_ID as integer),
Last_Name,
First_Name,
Title,
case
    -- YYYY-MM-DD
    when Hire_Date ~ '^\d{4}-\d{2}-\d{2}$' then to_date(Hire_Date, 'YYYY-MM-DD')
    -- DD-MM-YYYY
    when Hire_Date ~ '^\d{2}-\d{2}-\d{4}$' then to_date(Hire_Date, 'DD-MM-YYYY')
    -- YYYY.MM.DD
    when Hire_Date ~ '^\d{4}.\d{2}.\d{2}$' then to_date(Hire_Date, 'YYYY.MM.DD')
    -- DD.MM.YYYY
    when Hire_Date ~ '^\d{2}.\d{2}.\d{4}$' then to_date(Hire_Date, 'DD.MM.YYYY')
    -- DD/MM/YYYY
    when Hire_Date ~ '^\d{2}/\d{2}/\d{4}$' then to_date(Hire_Date, 'DD/MM/YYYY')
    -- YYYY/MM/DD
    when Hire_Date ~ '^\d{4}/\d{2}/\d{2}$' then to_date(Hire_Date, 'YYYY/MM/DD')
    -- DD\MM\YYYY
    when Hire_Date ~ '^\d{2}\\d{2}\\d{4}$' then to_date(Hire_Date, 'DD\MM\YYYY')
    -- YYYY\MM\DD
    when Hire_Date ~ '^\d{4}\\d{2}\\d{2}$' then to_date(Hire_Date, 'YYYY\MM\DD')
    else '1900-01-01' end,  
case when Office similar to '[0-9]+' then cast(Office as int) else 0 end,
case when Reports_To similar to '[0-9]+' then cast(Reports_To as int) else 0 end,
case when Month_Salary is null then null else cast(Month_Salary as decimal(15,5)) end
from MRR_Dim_Employees;

insert into DWH_Dim_Dates(Date,Year,Quarter,Month,Day)
select
generate_series::date,
extract(year from generate_series),
extract(quarter from generate_series),
extract(month from generate_series),
extract(day from generate_series)
from generate_series('2018-01-01'::date, CURRENT_DATE::date, '1 day');


insert into STG_Dim_Time(DateTime, Date, Hour)
select
generate_series::timestamp,
date_trunc('hour', generate_series::timestamp),
time '00:00:00' + (generate_series::timestamp - date_trunc('hour', generate_series::timestamp))
from generate_series('2018-01-01'::timestamp, CURRENT_DATE::timestamp, '1 hour');

