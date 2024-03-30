truncate table DWH_Dim_Products_Backup;
truncate table DWH_Dim_Customers_Backup;
truncate table DWH_Dim_Employees_Backup;
truncate table DWH_Dim_Dates_Backup;
truncate table DWH_Dim_Time_Backup;
truncate table DWH_Fact_Product_In_Order_Backup;
truncate table DWH_Snapshot_Customers_Transactions_Backup;


insert into DWH_Dim_Products_Backup(DW_Prdocut_ID,Product_ID,Product_Name,Supplier,Category,Unit_Price,Unit_Cost,Valid_From,Valid_Until)
select * from DWH_Dim_Products;


insert into DWH_Dim_Customers_Backup(DW_Customer_ID,Customer_ID,Company_Name,Contact_Name,Street,City,Postal_Code,Country,Phone,Fax,Valid_From,Valid_Until)
select * from DWH_Dim_Customers;


insert into DWH_Dim_Employees_Backup(DW_Employee_ID,Employee_ID,Last_Name,First_Name,Title,Hire_Date,Office,Reports_To,Month_Salary,Valid_From,Valid_Until)
select * from DWH_Dim_Employees;


insert into DWH_Dim_Dates_Backup(Date,Year,Quarter,Month,Day)
select * from DWH_Dim_Dates;


insert into DWH_Dim_Time_Backup(timestamp,Date,Hour)
select * from DWH_Dim_Time;


insert into DWH_Fact_Product_In_Order_Backup(Order_ID,DW_Prdocut_ID,DW_Customer_ID,DW_Employee_ID,Order_Time,Quantity,Total_Price, Total_Cost,Shipper_ID)
select * from DWH_Fact_Product_In_Order;


insert into DWH_Snapshot_Customers_Transactions_Backup(Year,Quarter,Month,Country,Count_New_Customers,Count_Regular,Count_Reactivated,Count_Abandons,Count_Total)
select * from DWH_Snapshot_Customers_Transactions;