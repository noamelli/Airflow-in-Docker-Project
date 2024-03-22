update STG_Fact_Orders
set Customer_ID=0
where Customer_ID not in (
                            select distinct Customer_ID 
                            from DWH_Dim_Customers
                        );

update STG_Fact_Orders
set Employee_ID=0
where Employee_ID not in (
                            select distinct Employee_ID 
                            from DWH_Dim_Employees
                        );

update STG_Fact_Details
set Product_ID=0
where Product_ID not in (
                            select distinct Product_ID 
                            from DWH_Dim_Products
                        );

