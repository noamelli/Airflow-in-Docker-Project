insert into DWH_Fact_Product_In_Order (Order_ID,DW_Prdocut_ID,DW_Customer_ID,DW_Employee_ID,Order_Time,Quantity,Total_Price,Total_Cost,Shipper_ID)
select 
o.Order_ID,
p.DW_Prdocut_ID,
c.DW_Customer_ID,
e.DW_Employee_ID,
o.Order_Time,
d.Quantity,
(d.Quantity * p.Unit_Price) as Total_Price,
(d.Quantity * p.Unit_Cost) as Total_Cost,
Shipper_ID
from STG_Fact_Orders o 
join STG_Fact_Details d on o.Order_ID=d.Order_ID 
join DWH_Dim_Customers c on o.Customer_ID=c.Customer_ID
join DWH_Dim_Employees e on o.Employee_ID=e.Employee_ID
join DWH_Dim_Products p on d.Product_ID=p.Product_ID
where p.Valid_Until is not null and e.Valid_Until is not null and c.Valid_Until is not null 