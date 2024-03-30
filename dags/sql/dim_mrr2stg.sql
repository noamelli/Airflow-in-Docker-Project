insert into STG_Dim_Products(Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select 
cast(Product_ID as integer),
case when Product_Name is null then 'missing' else Product_Name end,
case when Supplier similar to '[0-9]+' then cast(Supplier as integer) else 0 end,
case when Category similar to '[0-9]+' then cast(Category as integer) else 0 end,
case when Unit_Price similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Price as decimal(15,5))>=0
    then cast(Unit_Price as decimal(15,5)) else null end,
case when Unit_Cost similar to '[0-9]+(\.[0-9]+)?' and cast(Unit_Cost as decimal(15,5))>=0
    then cast(Unit_Cost as decimal(15,5)) else null end
from MRR_Dim_Products
where isValid='valid';

insert into STG_Dim_Customers(Customer_ID,Company_Name,Contact_Name,Street,City,Postal_Code,Country,Phone,Fax)
select
cast(Customer_ID as integer),
case when Company_Name is null then 'missing' else Company_Name end,
case when Contact_Name is null then 'missing' else Contact_Name end,
case when Street is null then 'missing' else Street end,
case when City is null then 'missing' else City end,
case when Postal_Code is null then 'missing' else Postal_Code end,
case when Country is null then 'missing' else Country end,
case when Phone is null then 'missing' else Phone end,
case when Fax is null then 'missing' else Fax end 
from MRR_Dim_Customers
where isValid='valid';

insert into STG_Dim_Employees(Employee_ID,Last_Name,First_Name,Title,Hire_Date,Office,Reports_To,Month_Salary)
select 
cast(Employee_ID as integer),
case when Last_Name is null then 'missing' else Last_Name end,
case when First_Name is null then 'missing' else First_Name end ,
case when Title is null then 'missing' else Title end ,
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
case when Reports_To similar to '[0-9]+' then cast(Reports_To as int) when Reports_To is null then null else 0 end,
case when Month_Salary similar to '[0-9]+(\.[0-9]+)?' and cast(Month_Salary as decimal(15,5))>=0
    then cast(Month_Salary as decimal(15,5)) else null end
from MRR_Dim_Employees
where isValid='valid';


insert into STG_Dim_Dates(Date,Year,Quarter,Month,Day)
select
generate_series::date,
extract(year from generate_series),
extract(quarter from generate_series),
extract(month from generate_series),
extract(day from generate_series)
from generate_series('2018-01-01'::date, CURRENT_DATE::date, '1 day');


insert into STG_Dim_Time(DateTime, Date, Hour)
SELECT
  generate_series::TIMESTAMP,
  DATE_TRUNC('hour', generate_series::TIMESTAMP),
  EXTRACT(HOUR FROM generate_series::TIMESTAMP) AS hour
FROM
  GENERATE_SERIES('2018-01-01'::TIMESTAMP, CURRENT_DATE::TIMESTAMP, '1 hour');

