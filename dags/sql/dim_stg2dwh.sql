truncate table DWH_Dim_Dates;
truncate table DWH_Dim_Time;

insert into DWH_Dim_Dates (Date,Year,Quarter,Month,Day)
select * 
from STG_Dim_Dates;

insert into DWH_Dim_Time (DateTime,Date,Hour)
select * 
from STG_Dim_Time;

--customers
--insert all the new customers records 
insert into DWH_Dim_Customers (Customer_ID,Company_Name,Contact_Name,Street,City,Postal_Code,Country,Phone,Fax)
select *
from STG_Dim_Customers  
where Customer_ID not in (
                          select distinct Customer_ID
                          from DWH_Dim_Customers
                          );



--update the valid until date of customers who moved to another city/country

update DWH_Dim_Customers
set Valid_Until=current_date
where DW_Customer_ID in (
                            select DW_Customer_ID 
                            from STG_Dim_Customers s inner join DWH_Dim_Customers d on d.Customer_ID = s.Customer_ID
                            where (s.City <> d.City or s.Country <> d.Country) and d.Valid_Until is null
                          );


--insert records of customers who moved to another city/country                             
insert into DWH_Dim_Customers (Customer_ID,Company_Name,Contact_Name,Street,City,Postal_Code,Country,Phone,Fax)
select s.Customer_ID,s.Company_Name,s.Contact_Name,s.Street,s.City,s.Postal_Code,s.Country,s.Phone,s.Fax
from STG_Dim_Customers s inner join DWH_Dim_Customers d on d.Customer_ID=s.Customer_ID
where s.City <> d.City or s.Country <> d.Country;

--products

-- insert all the new products records 
insert into DWH_Dim_Products (Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select *
from STG_Dim_Products s 
where Product_ID not in 
                            (
                              select distinct Product_ID
                              from DWH_Dim_Products       
                            );
-- update the valid until date of products that their price/cost/supplier have changed
update DWH_Dim_Products
set Valid_Until=current_date
where DW_Prdocut_ID in (
                            select DW_Prdocut_ID 
                            from STG_Dim_Products s inner join DWH_Dim_Products d on d.Product_ID = s.Product_ID
                            where (s.Unit_Cost <> d.Unit_Cost or s.Unit_Price <> d.Unit_Price or s.Supplier <> d.Supplier) 
                            and d.Valid_Until is null
                          );



-- insert records of products that their price/cost/supplier have changed                             
insert into DWH_Dim_Products (Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost)
select s.Product_ID,s.Product_Name,s.Supplier,s.Category,s.Unit_Price,s.Unit_Cost
from STG_Dim_Products s inner join DWH_Dim_Products d on d.Product_ID=s.Product_ID
where s.Unit_Cost <> d.Unit_Cost or s.Unit_Price <> d.Unit_Price or s.Supplier <> d.Supplier;

-- employees

-- insert all the new employees records 
insert into DWH_Dim_Employees (Employee_ID,Last_Name,First_Name,Title,Hire_Date,Office,Reports_To,Month_Salary)
select *
from STG_Dim_Employees 
where Employee_ID not in 
                            (
                              select distinct Employee_ID
                              from DWH_Dim_Employees       
                            );
--update the valid until date of employees that their salary/title/manager/office have changed
update DWH_Dim_Employees
set Valid_Until=current_date
where DWH_Dim_Employees in (
                            select DWH_Dim_Employees 
                            from STG_Dim_Employees s inner join DWH_Dim_Employees d on d.Employee_ID = s.Employee_ID
                            where (s.Reports_To <> d.Reports_To or s.title <> d.title or s.Month_Salary <> d.Month_Salary or s.office <> d.office) 
                            and d.Valid_Until is null
                          );

-- insert records of employees that their manager/title/salary/office have changed                             
insert into DWH_Dim_Employees (Employee_ID,Last_Name,First_Name,Title,Hire_Date,Office,Reports_To,Month_Salary)
select s.Employee_ID,s.Last_Name,s.First_Name,s.Title,s.Hire_Date,s.Office,s.Reports_To,s.Month_Salary
from STG_Dim_Employees s inner join DWH_Dim_Employees d on d.Employee_ID=s.Employee_ID
where s.Reports_To <> d.Reports_To or s.title <> d.title or s.Month_Salary <> d.Month_Salary or s.office <> d.office


